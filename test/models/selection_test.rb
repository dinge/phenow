# frozen_string_literal: true

require "test_helper"

class SelectionTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid selection" do
    assert_valid selections(:plant_1_keeper)
  end

  test "requires plant" do
    selection = Selection.new(user: users(:marcus), decision: "keep", selected_at: Time.current)
    assert_invalid selection, :plant
  end

  test "requires user" do
    selection = Selection.new(plant: plants(:plant_1), decision: "keep", selected_at: Time.current)
    assert_invalid selection, :user
  end

  test "requires decision" do
    selection = Selection.new(plant: plants(:plant_1), user: users(:marcus), selected_at: Time.current)
    assert_invalid selection, :decision
  end

  test "requires selected_at" do
    selection = Selection.new(plant: plants(:plant_1), user: users(:marcus), decision: "keep")
    assert_invalid selection, :selected_at
  end

  test "validates decision inclusion" do
    selection = selections(:plant_1_keeper)
    selection.decision = "invalid_decision"
    assert_invalid selection, :decision
  end

  test "requires reasoning" do
    selection = selections(:plant_1_keeper)
    selection.reasoning = nil
    assert_invalid selection, :reasoning
  end

  # === Associations ===

  test "belongs to plant" do
    assert_equal plants(:plant_1), selections(:plant_1_keeper).plant
  end

  test "belongs to user" do
    assert_equal users(:marcus), selections(:plant_1_keeper).user
  end

  # === Scopes ===

  test "keepers returns keep and breeding selections" do
    keepers = Selection.keepers
    assert keepers.all? { |s| ["keep", "breeding_mother", "breeding_father"].include?(s.decision) }
  end

  test "culls returns cull selections" do
    culls = Selection.culls
    assert culls.all? { |s| s.decision == "cull" }
    assert_includes culls, selections(:plant_2_cull)
  end

  test "recent returns selections ordered by selected_at desc" do
    recent = Selection.recent
    assert recent.first.selected_at >= recent.last.selected_at
  end

  # === Instance Methods ===

  test "keeper? returns true for keeper decisions" do
    assert selections(:plant_1_keeper).keeper?
    assert selections(:plant_4_keeper).keeper?
    assert_not selections(:plant_2_cull).keeper?
  end

  test "cull? returns true for cull decision" do
    assert selections(:plant_2_cull).cull?
    assert_not selections(:plant_1_keeper).cull?
  end

  test "breeding_mother? returns true for breeding_mother decision" do
    assert selections(:plant_1_keeper).breeding_mother?
    assert_not selections(:plant_4_keeper).breeding_mother?
  end

  # === Constants ===

  test "DECISIONS contains valid decisions" do
    assert_includes Selection::DECISIONS, "keep"
    assert_includes Selection::DECISIONS, "cull"
    assert_includes Selection::DECISIONS, "breeding_mother"
    assert_includes Selection::DECISIONS, "breeding_father"
    assert_includes Selection::DECISIONS, "further_evaluation"
  end
end
