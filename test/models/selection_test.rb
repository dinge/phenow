# frozen_string_literal: true

require "test_helper"

class SelectionTest < ActiveSupport::TestCase
  fixtures :users, :organizations, :teams, :memberships, :projects, :strains, :plants, :selections

  # === Validations ===

  test "valid selection" do
    assert_valid selections(:plant_1_keeper)
  end

  test "requires plant" do
    selection = Selection.new(selected_by: users(:marcus), decision: "keep", selected_at: Time.current)
    assert_invalid selection, :plant
  end

  test "requires selected_by" do
    selection = Selection.new(plant: plants(:plant_1), decision: "keep", selected_at: Time.current)
    assert_invalid selection, :selected_by
  end

  test "requires decision" do
    selection = Selection.new(plant: plants(:plant_1), selected_by: users(:marcus), selected_at: Time.current)
    assert_invalid selection, :decision
  end

  test "auto-sets selected_at to current time" do
    selection = Selection.new(plant: plants(:plant_1), selected_by: users(:marcus), decision: "keep", reasoning: "Test")
    selection.valid?
    assert_not_nil selection.selected_at
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

  test "belongs to selected_by user" do
    assert_equal users(:marcus), selections(:plant_1_keeper).selected_by
  end

  # === Scopes ===

  test "keepers scope returns keep decisions" do
    keepers = Selection.keepers
    assert keepers.all? { |s| s.decision == "keep" }
    assert_includes keepers, selections(:plant_4_keeper)
  end

  test "culled scope returns cull decisions" do
    culled = Selection.culled
    assert culled.all? { |s| s.decision == "cull" }
    assert_includes culled, selections(:plant_2_cull)
  end

  test "reverse_chronological returns selections ordered by selected_at desc" do
    recent = Selection.reverse_chronological
    assert recent.first.selected_at >= recent.last.selected_at
  end

  # === Instance Methods ===

  test "keeper? returns true for keep decisions" do
    assert selections(:plant_4_keeper).keeper?
    assert_not selections(:plant_2_cull).keeper?
  end

  test "culled? returns true for cull decisions" do
    assert selections(:plant_2_cull).culled?
    assert_not selections(:plant_1_keeper).culled?
  end

  test "breeding_stock? returns true for breeding decisions" do
    assert selections(:plant_1_keeper).breeding_stock?
    assert_not selections(:plant_4_keeper).breeding_stock?
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
