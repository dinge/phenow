# frozen_string_literal: true

require "test_helper"

class TraitDefinitionTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid trait definition" do
    assert_valid trait_definitions(:overall_vigor)
  end

  test "requires name" do
    trait = TraitDefinition.new(
      trait_category: trait_categories(:vigor_health),
      data_type: "scale"
    )
    assert_invalid trait, :name
  end

  test "requires data_type" do
    trait = TraitDefinition.new(
      trait_category: trait_categories(:vigor_health),
      name: "Test Trait"
    )
    assert_invalid trait, :data_type
  end

  test "validates data_type inclusion" do
    trait = trait_definitions(:overall_vigor)
    trait.data_type = "invalid"
    assert_invalid trait, :data_type
  end

  test "requires trait_category" do
    trait = TraitDefinition.new(name: "Test", data_type: "scale")
    assert_invalid trait, :trait_category
  end

  # === Associations ===

  test "belongs to trait category" do
    assert_equal trait_categories(:vigor_health), trait_definitions(:overall_vigor).trait_category
  end

  test "belongs to organization (optional)" do
    # System defaults have nil organization
    assert_nil trait_definitions(:overall_vigor).organization
  end

  test "has many trait values" do
    assert_respond_to trait_definitions(:overall_vigor), :trait_values
    assert trait_definitions(:overall_vigor).trait_values.count > 0
  end

  # === Scopes ===

  test "system_defaults returns traits with nil organization" do
    system_traits = TraitDefinition.system_defaults
    assert system_traits.all? { |t| t.organization_id.nil? }
  end

  test "for_stage returns traits applicable to stage" do
    veg_traits = TraitDefinition.for_stage("vegetative")
    assert veg_traits.all? { |t| t.applicable_stages.include?("vegetative") }
    assert_includes veg_traits, trait_definitions(:overall_vigor)
    assert_includes veg_traits, trait_definitions(:height)
  end

  test "by_type returns traits of specific data type" do
    scale_traits = TraitDefinition.by_type("scale")
    assert scale_traits.all? { |t| t.data_type == "scale" }
    assert_includes scale_traits, trait_definitions(:overall_vigor)
  end

  # === Instance Methods ===

  test "numeric? returns true for numeric type" do
    assert trait_definitions(:height).numeric?
    assert_not trait_definitions(:overall_vigor).numeric?
  end

  test "scale? returns true for scale type" do
    assert trait_definitions(:overall_vigor).scale?
    assert_not trait_definitions(:height).scale?
  end

  test "select? returns true for select type" do
    assert trait_definitions(:bud_structure).select?
    assert_not trait_definitions(:height).select?
  end

  test "applicable_to_stage? checks stage applicability" do
    vigor = trait_definitions(:overall_vigor)
    assert vigor.applicable_to_stage?("vegetative")
    assert vigor.applicable_to_stage?("flowering")
    assert_not vigor.applicable_to_stage?("harvest")
  end

  # === Constants ===

  test "DATA_TYPES contains valid types" do
    assert_includes TraitDefinition::DATA_TYPES, "numeric"
    assert_includes TraitDefinition::DATA_TYPES, "scale"
    assert_includes TraitDefinition::DATA_TYPES, "select"
    assert_includes TraitDefinition::DATA_TYPES, "boolean"
    assert_includes TraitDefinition::DATA_TYPES, "text"
  end
end
