# frozen_string_literal: true

require "test_helper"

class StrainLineageTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid strain lineage" do
    assert_valid strain_lineages(:gmo_x_zkittlez_mother)
  end

  test "requires parent strain" do
    lineage = StrainLineage.new(
      child_strain: strains(:gmo_x_zkittlez),
      parent_role: "mother"
    )
    assert_invalid lineage, :parent_strain
  end

  test "requires child strain" do
    lineage = StrainLineage.new(
      parent_strain: strains(:gmo),
      parent_role: "mother"
    )
    assert_invalid lineage, :child_strain
  end

  test "requires parent role" do
    lineage = StrainLineage.new(
      parent_strain: strains(:gmo),
      child_strain: strains(:gmo_x_zkittlez)
    )
    assert_invalid lineage, :parent_role
  end

  test "validates parent_role inclusion" do
    lineage = strain_lineages(:gmo_x_zkittlez_mother)
    lineage.parent_role = "invalid"
    assert_invalid lineage, :parent_role
  end

  # === Associations ===

  test "belongs to parent strain" do
    assert_equal strains(:gmo), strain_lineages(:gmo_x_zkittlez_mother).parent_strain
  end

  test "belongs to child strain" do
    assert_equal strains(:gmo_x_zkittlez), strain_lineages(:gmo_x_zkittlez_mother).child_strain
  end

  # === Instance Methods ===

  test "mother? returns true for mother role" do
    assert strain_lineages(:gmo_x_zkittlez_mother).mother?
    assert_not strain_lineages(:gmo_x_zkittlez_father).mother?
  end

  test "father? returns true for father role" do
    assert strain_lineages(:gmo_x_zkittlez_father).father?
    assert_not strain_lineages(:gmo_x_zkittlez_mother).father?
  end

  # === Constants ===

  test "PARENT_ROLES contains valid roles" do
    assert_includes StrainLineage::PARENT_ROLES, "mother"
    assert_includes StrainLineage::PARENT_ROLES, "father"
  end
end
