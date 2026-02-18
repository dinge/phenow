# frozen_string_literal: true

require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid tagging" do
    assert_valid taggings(:plant_1_keeper)
  end

  test "requires tag" do
    tagging = Tagging.new(taggable: plants(:plant_1))
    assert_invalid tagging, :tag
  end

  test "unique tag per taggable" do
    duplicate = Tagging.new(
      tag: tags(:keeper_tag),
      taggable: plants(:plant_1)
    )
    assert_invalid duplicate, :tag_id
  end

  # === Associations ===

  test "belongs to tag" do
    assert_equal tags(:keeper_tag), taggings(:plant_1_keeper).tag
  end

  test "polymorphic taggable - Plant" do
    tagging = taggings(:plant_1_keeper)
    assert_equal "Plant", tagging.taggable_type
    assert_equal plants(:plant_1), tagging.taggable
  end

  test "polymorphic taggable - Project" do
    tagging = taggings(:project_priority)
    assert_equal "Project", tagging.taggable_type
    assert_equal projects(:gmo_zkittlez_hunt), tagging.taggable
  end

  test "polymorphic taggable - Strain" do
    tagging = taggings(:strain_terpy)
    assert_equal "Strain", tagging.taggable_type
    assert_equal strains(:zkittlez), tagging.taggable
  end
end
