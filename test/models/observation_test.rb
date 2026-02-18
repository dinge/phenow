# frozen_string_literal: true

require "test_helper"

class ObservationTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid observation" do
    assert_valid observations(:obs_1_seedling)
  end

  test "requires plant" do
    observation = Observation.new(observed_by: users(:marcus), observed_at: Time.current)
    assert_invalid observation, :plant
  end

  test "requires user" do
    observation = Observation.new(plant: plants(:plant_1), observed_at: Time.current)
    assert_invalid observation, :observed_by
  end

  test "requires observed_at" do
    observation = Observation.new(plant: plants(:plant_1), observed_by: users(:marcus))
    assert_invalid observation, :observed_at
  end

  test "validates stage inclusion when present" do
    observation = observations(:obs_1_seedling)
    observation.stage = "invalid_stage"
    assert_invalid observation, :stage
  end

  # === Associations ===

  test "belongs to plant" do
    assert_equal plants(:plant_1), observations(:obs_1_seedling).plant
  end

  test "belongs to user" do
    assert_equal users(:marcus), observations(:obs_1_seedling).user
  end

  test "has many trait values" do
    assert_respond_to observations(:obs_1_seedling), :trait_values
    assert observations(:obs_1_seedling).trait_values.count > 0
  end

  test "has many photos" do
    assert_respond_to observations(:obs_1_flowering), :photos
  end

  test "has many comments" do
    assert_respond_to observations(:obs_1_flowering), :comments
  end

  # === Scopes ===

  test "for_stage returns observations at specific stage" do
    flowering = Observation.for_stage("flowering")
    assert flowering.all? { |o| o.stage == "flowering" }
  end

  test "recent returns observations ordered by observed_at desc" do
    recent = Observation.recent
    assert recent.first.observed_at >= recent.last.observed_at
  end

  test "by_user returns observations by specific user" do
    marcus_obs = Observation.by_user(users(:marcus))
    assert marcus_obs.all? { |o| o.user == users(:marcus) }
  end

  # === Instance Methods ===

  test "project returns plant's project" do
    assert_equal projects(:gmo_zkittlez_hunt), observations(:obs_1_seedling).project
  end

  test "organization returns plant's organization" do
    assert_equal organizations(:exotic_genetics), observations(:obs_1_seedling).organization
  end
end
