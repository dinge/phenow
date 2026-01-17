# frozen_string_literal: true

require "test_helper"

class StrainTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid strain" do
    assert_valid strains(:gmo)
  end

  test "requires name" do
    strain = Strain.new(organization: organizations(:exotic_genetics), slug: "test")
    assert_invalid strain, :name
  end

  test "requires organization" do
    strain = Strain.new(name: "Test Strain", slug: "test")
    assert_invalid strain, :organization
  end

  test "requires unique slug within organization" do
    duplicate = Strain.new(
      organization: organizations(:exotic_genetics),
      name: "Different Name",
      slug: strains(:gmo).slug
    )
    assert_invalid duplicate, :slug
  end

  test "validates strain_type inclusion" do
    strain = strains(:gmo)
    strain.strain_type = "invalid"
    assert_invalid strain, :strain_type
  end

  test "validates genetics_type inclusion" do
    strain = strains(:gmo)
    strain.genetics_type = "invalid"
    assert_invalid strain, :genetics_type
  end

  # === Associations ===

  test "belongs to organization" do
    assert_equal organizations(:exotic_genetics), strains(:gmo).organization
  end

  test "has many parent lineages" do
    assert_respond_to strains(:gmo_x_zkittlez), :parent_lineages
    assert strains(:gmo_x_zkittlez).parent_lineages.count == 2
  end

  test "has many parent strains through lineages" do
    assert_respond_to strains(:gmo_x_zkittlez), :parent_strains
    assert_includes strains(:gmo_x_zkittlez).parent_strains, strains(:gmo)
    assert_includes strains(:gmo_x_zkittlez).parent_strains, strains(:zkittlez)
  end

  test "has many child lineages" do
    assert_respond_to strains(:gmo), :child_lineages
    assert strains(:gmo).child_lineages.count > 0
  end

  test "has many child strains through lineages" do
    assert_respond_to strains(:gmo), :child_strains
    assert_includes strains(:gmo).child_strains, strains(:gmo_x_zkittlez)
  end

  test "has many projects" do
    assert_respond_to strains(:gmo_x_zkittlez), :projects
  end

  test "has many plants" do
    assert_respond_to strains(:gmo_x_zkittlez), :plants
  end

  # === Scopes ===

  test "public_strains returns public strains" do
    public_strains = Strain.public_strains
    assert public_strains.all?(&:public)
    assert_includes public_strains, strains(:gmo)
    assert_not_includes public_strains, strains(:gmo_x_zkittlez)
  end

  test "verified returns verified strains" do
    verified = Strain.verified
    assert verified.all?(&:verified)
    assert_includes verified, strains(:gmo)
  end

  test "by_type filters by strain type" do
    indicas = Strain.by_type("indica")
    assert indicas.all? { |s| s.strain_type == "indica" }
    assert_includes indicas, strains(:gmo)
  end

  # === Instance Methods ===

  test "mother returns mother strain" do
    assert_equal strains(:gmo), strains(:gmo_x_zkittlez).mother
  end

  test "father returns father strain" do
    assert_equal strains(:zkittlez), strains(:gmo_x_zkittlez).father
  end

  test "full_lineage returns lineage text if present" do
    strain = strains(:gmo)
    assert_equal strain.lineage_text, strain.full_lineage
  end

  test "full_lineage returns parent names if no lineage text" do
    strain = strains(:gmo_x_zkittlez)
    strain.lineage_text = nil
    lineage = strain.full_lineage
    assert_includes lineage, "GMO"
    assert_includes lineage, "Zkittlez"
  end

  # === Constants ===

  test "STRAIN_TYPES contains valid types" do
    assert_includes Strain::STRAIN_TYPES, "indica"
    assert_includes Strain::STRAIN_TYPES, "sativa"
    assert_includes Strain::STRAIN_TYPES, "hybrid"
    assert_includes Strain::STRAIN_TYPES, "ruderalis"
  end

  test "GENETICS_TYPES contains valid types" do
    assert_includes Strain::GENETICS_TYPES, "regular"
    assert_includes Strain::GENETICS_TYPES, "feminized"
    assert_includes Strain::GENETICS_TYPES, "autoflower"
  end
end
