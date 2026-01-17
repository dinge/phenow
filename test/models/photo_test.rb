# frozen_string_literal: true

require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid photo" do
    assert_valid photos(:plant_1_veg_photo)
  end

  test "validates stage inclusion when present" do
    photo = photos(:plant_1_veg_photo)
    photo.stage = "invalid"
    assert_invalid photo, :stage
  end

  # === Associations ===

  test "polymorphic photographable - Plant" do
    photo = photos(:plant_1_veg_photo)
    assert_equal "Plant", photo.photographable_type
    assert_equal plants(:plant_1), photo.photographable
  end

  test "polymorphic photographable - Observation" do
    photo = photos(:obs_plant_1_w4_photo)
    assert_equal "Observation", photo.photographable_type
    assert_equal observations(:plant_1_week_4_flower), photo.photographable
  end

  # === Scopes ===

  test "for_stage returns photos at specific stage" do
    flowering_photos = Photo.for_stage("flowering")
    assert flowering_photos.all? { |p| p.stage == "flowering" }
  end

  test "recent returns photos ordered by taken_at desc" do
    recent = Photo.recent
    # Photos with taken_at should be sorted
    with_dates = recent.select { |p| p.taken_at.present? }
    assert with_dates.first.taken_at >= with_dates.last.taken_at if with_dates.length > 1
  end

  # === Instance Methods ===

  test "plant returns plant for Plant photographable" do
    photo = photos(:plant_1_veg_photo)
    assert_equal plants(:plant_1), photo.plant
  end

  test "plant returns observation's plant for Observation photographable" do
    photo = photos(:obs_plant_1_w4_photo)
    assert_equal plants(:plant_1), photo.plant
  end
end
