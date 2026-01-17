# frozen_string_literal: true

require "test_helper"

class PlantTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid plant" do
    assert_valid plants(:plant_1)
  end

  test "requires project" do
    plant = Plant.new(identifier: "#99", source_type: "seed")
    assert_invalid plant, :project
  end

  test "requires identifier" do
    plant = plants(:plant_1)
    plant.identifier = nil
    assert_invalid plant, :identifier
  end

  test "identifier unique within project" do
    duplicate = Plant.new(
      project: projects(:gmo_zkittlez_hunt),
      identifier: "#1",
      source_type: "seed"
    )
    assert_invalid duplicate, :identifier
  end

  test "allows same identifier in different projects" do
    plant = Plant.new(
      project: projects(:purple_punch_preservation),
      identifier: "#1",
      source_type: "clone"
    )
    assert_valid plant
  end

  test "validates source_type inclusion" do
    plant = plants(:plant_1)
    plant.source_type = "invalid"
    assert_invalid plant, :source_type
  end

  test "validates sex inclusion" do
    plant = plants(:plant_1)
    plant.sex = "invalid"
    assert_invalid plant, :sex
  end

  test "validates current_stage inclusion" do
    plant = plants(:plant_1)
    plant.current_stage = "invalid"
    assert_invalid plant, :current_stage
  end

  test "validates status inclusion" do
    plant = plants(:plant_1)
    plant.status = "invalid"
    assert_invalid plant, :status
  end

  # === Associations ===

  test "belongs to project" do
    assert_equal projects(:gmo_zkittlez_hunt), plants(:plant_1).project
  end

  test "belongs to strain" do
    assert_equal strains(:gmo_x_zkittlez), plants(:plant_1).strain
  end

  test "has many stage transitions" do
    assert_respond_to plants(:plant_1), :plant_stage_transitions
    assert plants(:plant_1).plant_stage_transitions.count > 0
  end

  test "has many observations" do
    assert_respond_to plants(:plant_1), :observations
    assert plants(:plant_1).observations.count > 0
  end

  test "has many trait values through observations" do
    assert_respond_to plants(:plant_1), :trait_values
  end

  test "has many photos" do
    assert_respond_to plants(:plant_1), :photos
  end

  test "has one lab test" do
    assert_respond_to plants(:plant_1), :lab_test
    assert_not_nil plants(:plant_1).lab_test
  end

  test "has many selections" do
    assert_respond_to plants(:plant_1), :selections
    assert plants(:plant_1).selections.count > 0
  end

  # === Scopes ===

  test "keepers returns keeper plants" do
    keepers = Plant.keepers
    assert keepers.all? { |p| p.status == "keeper" }
    assert_includes keepers, plants(:plant_1)
  end

  test "active returns active plants" do
    active = Plant.active
    assert active.all? { |p| p.status == "active" }
    assert_includes active, plants(:plant_3)
  end

  test "culled returns culled plants" do
    culled = Plant.culled
    assert culled.all? { |p| p.status == "culled" }
    assert_includes culled, plants(:plant_2)
  end

  test "female returns female plants" do
    females = Plant.female
    assert females.all? { |p| p.sex == "female" }
    assert_includes females, plants(:plant_1)
    assert_not_includes females, plants(:plant_2)
  end

  test "male returns male plants" do
    males = Plant.male
    assert males.all? { |p| p.sex == "male" }
    assert_includes males, plants(:plant_2)
  end

  test "in_stage returns plants in specific stage" do
    flowering = Plant.in_stage("flowering")
    assert flowering.all? { |p| p.current_stage == "flowering" }
    assert_includes flowering, plants(:plant_3)
  end

  # === Instance Methods ===

  test "keeper? returns true for keeper status" do
    assert plants(:plant_1).keeper?
    assert_not plants(:plant_3).keeper?
  end

  test "culled? returns true for culled status" do
    assert plants(:plant_2).culled?
    assert_not plants(:plant_1).culled?
  end

  test "female? returns true for female sex" do
    assert plants(:plant_1).female?
    assert_not plants(:plant_2).female?
  end

  test "male? returns true for male sex" do
    assert plants(:plant_2).male?
    assert_not plants(:plant_1).male?
  end

  test "days_in_flower calculates correctly" do
    plant = plants(:plant_3)
    expected = (Date.current - plant.flip_date).to_i
    assert_equal expected, plant.days_in_flower
  end

  test "days_in_flower returns nil without flip date" do
    plant = plants(:plant_8)
    assert_nil plant.days_in_flower
  end

  test "organization returns project's team's organization" do
    assert_equal organizations(:exotic_genetics), plants(:plant_1).organization
  end

  # === Constants ===

  test "STATUSES contains valid statuses" do
    assert_includes Plant::STATUSES, "active"
    assert_includes Plant::STATUSES, "keeper"
    assert_includes Plant::STATUSES, "culled"
    assert_includes Plant::STATUSES, "harvested"
    assert_includes Plant::STATUSES, "archived"
  end

  test "STAGES contains valid stages" do
    assert_includes Plant::STAGES, "germination"
    assert_includes Plant::STAGES, "seedling"
    assert_includes Plant::STAGES, "vegetative"
    assert_includes Plant::STAGES, "flowering"
    assert_includes Plant::STAGES, "harvest"
  end
end
