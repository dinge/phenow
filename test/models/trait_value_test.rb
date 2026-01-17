# frozen_string_literal: true

require "test_helper"

class TraitValueTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid trait value" do
    assert_valid trait_values(:plant_1_w1_vigor)
  end

  test "requires observation" do
    tv = TraitValue.new(trait_definition: trait_definitions(:overall_vigor), numeric_value: 8)
    assert_invalid tv, :observation
  end

  test "requires trait definition" do
    tv = TraitValue.new(observation: observations(:plant_1_week_1), numeric_value: 8)
    assert_invalid tv, :trait_definition
  end

  # === Associations ===

  test "belongs to observation" do
    assert_equal observations(:plant_1_week_1), trait_values(:plant_1_w1_vigor).observation
  end

  test "belongs to trait definition" do
    assert_equal trait_definitions(:overall_vigor), trait_values(:plant_1_w1_vigor).trait_definition
  end

  # === Value Access ===

  test "numeric value stored correctly" do
    tv = trait_values(:plant_1_w1_vigor)
    assert_equal 8, tv.numeric_value
  end

  test "text value stored correctly" do
    tv = trait_values(:plant_1_w4f_primary_aroma)
    assert_equal "tropical", tv.text_value
  end

  test "value returns numeric_value for scale traits" do
    tv = trait_values(:plant_1_w1_vigor)
    assert_equal 8, tv.value
  end

  test "value returns text_value for select traits" do
    tv = trait_values(:plant_1_w4f_primary_aroma)
    assert_equal "tropical", tv.value
  end

  # === Delegation ===

  test "plant returns observation's plant" do
    tv = trait_values(:plant_1_w1_vigor)
    assert_equal plants(:plant_1), tv.plant
  end

  test "user returns observation's user" do
    tv = trait_values(:plant_1_w1_vigor)
    assert_equal users(:marcus), tv.user
  end
end
