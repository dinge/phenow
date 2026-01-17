# frozen_string_literal: true

require "test_helper"

class TraitCategoryTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid trait category" do
    assert_valid trait_categories(:vigor_health)
  end

  test "requires name" do
    category = TraitCategory.new(slug: "test")
    assert_invalid category, :name
  end

  test "requires unique slug" do
    duplicate = TraitCategory.new(
      name: "Different Name",
      slug: trait_categories(:vigor_health).slug
    )
    assert_invalid duplicate, :slug
  end

  # === Associations ===

  test "belongs to organization (optional)" do
    # System defaults have nil organization
    assert_nil trait_categories(:vigor_health).organization
  end

  test "has many trait definitions" do
    assert_respond_to trait_categories(:vigor_health), :trait_definitions
    assert trait_categories(:vigor_health).trait_definitions.count > 0
  end

  # === Scopes ===

  test "system_defaults returns categories with nil organization" do
    system_cats = TraitCategory.system_defaults
    assert system_cats.all? { |c| c.organization_id.nil? }
  end

  test "ordered returns categories by display_order" do
    ordered = TraitCategory.ordered
    orders = ordered.map(&:display_order)
    assert_equal orders, orders.sort
  end

  # === Instance Methods ===

  test "trait_count returns number of definitions" do
    count = trait_categories(:vigor_health).trait_count
    assert count > 0
  end
end
