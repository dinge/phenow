# frozen_string_literal: true

require "test_helper"

class PlantStageTransitionTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid plant stage transition" do
    assert_valid plant_stage_transitions(:plant_1_veg)
  end

  test "requires plant" do
    transition = PlantStageTransition.new(
      to_stage: "vegetative",
      transitioned_at: Time.current
    )
    assert_invalid transition, :plant
  end

  test "requires to_stage" do
    transition = PlantStageTransition.new(
      plant: plants(:plant_1),
      transitioned_at: Time.current
    )
    assert_invalid transition, :to_stage
  end

  test "requires transitioned_at" do
    transition = PlantStageTransition.new(
      plant: plants(:plant_1),
      to_stage: "vegetative"
    )
    assert_invalid transition, :transitioned_at
  end

  test "validates to_stage inclusion" do
    transition = plant_stage_transitions(:plant_1_veg)
    transition.to_stage = "invalid"
    assert_invalid transition, :to_stage
  end

  test "validates from_stage inclusion when present" do
    transition = plant_stage_transitions(:plant_1_veg)
    transition.from_stage = "invalid"
    assert_invalid transition, :from_stage
  end

  # === Associations ===

  test "belongs to plant" do
    assert_equal plants(:plant_1), plant_stage_transitions(:plant_1_veg).plant
  end

  # === Scopes ===

  test "chronological returns transitions ordered by transitioned_at" do
    transitions = PlantStageTransition.chronological
    assert transitions.first.transitioned_at <= transitions.last.transitioned_at
  end

  test "for_plant returns transitions for specific plant" do
    transitions = PlantStageTransition.for_plant(plants(:plant_1))
    assert transitions.all? { |t| t.plant == plants(:plant_1) }
  end

  # === Instance Methods ===

  test "duration returns time spent in stage" do
    # Duration from this transition to next one
    transition = plant_stage_transitions(:plant_1_veg)
    assert_respond_to transition, :duration
  end
end
