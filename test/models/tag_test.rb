# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid tag" do
    assert_valid tags(:keeper_tag)
  end

  test "requires name" do
    tag = Tag.new(organization: organizations(:exotic_genetics), slug: "test")
    assert_invalid tag, :name
  end

  test "requires organization" do
    tag = Tag.new(name: "Test Tag", slug: "test")
    assert_invalid tag, :organization
  end

  test "requires unique slug within organization" do
    duplicate = Tag.new(
      organization: organizations(:exotic_genetics),
      name: "Different Name",
      slug: tags(:keeper_tag).slug
    )
    assert_invalid duplicate, :slug
  end

  test "allows same slug in different organizations" do
    tag = Tag.new(
      organization: organizations(:west_coast_seeds),
      name: "Keeper",
      slug: "keeper"
    )
    assert_valid tag
  end

  # === Associations ===

  test "belongs to organization" do
    assert_equal organizations(:exotic_genetics), tags(:keeper_tag).organization
  end

  test "has many taggings" do
    assert_respond_to tags(:keeper_tag), :taggings
    assert tags(:keeper_tag).taggings.count > 0
  end

  # === Instance Methods ===

  test "usage_count returns number of taggings" do
    assert tags(:keeper_tag).usage_count > 0
  end
end
