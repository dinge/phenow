# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid organization" do
    assert_valid organizations(:exotic_genetics)
  end

  test "requires name" do
    org = Organization.new(slug: "test-org")
    assert_invalid org, :name
  end

  test "requires unique slug" do
    duplicate = Organization.new(
      name: "Different Name",
      slug: organizations(:exotic_genetics).slug
    )
    assert_invalid duplicate, :slug
  end

  # === Associations ===

  test "has many teams" do
    assert_respond_to organizations(:exotic_genetics), :teams
    assert_includes organizations(:exotic_genetics).teams, teams(:breeding_team)
  end

  test "has many strains" do
    assert_respond_to organizations(:exotic_genetics), :strains
    assert organizations(:exotic_genetics).strains.count > 0
  end

  test "has many trait categories" do
    assert_respond_to organizations(:exotic_genetics), :trait_categories
  end

  test "has many tags" do
    assert_respond_to organizations(:exotic_genetics), :tags
    assert organizations(:exotic_genetics).tags.count > 0
  end

  # === Class Methods ===

  test "default creates system organization" do
    # Clear any existing system org
    Organization.where(slug: "system").destroy_all

    org = Organization.default
    assert_equal "Phenow System", org.name
    assert_equal "system", org.slug
    assert org.settings["system"]
  end

  test "default returns existing system organization" do
    # Create system org first
    Organization.where(slug: "system").destroy_all
    first = Organization.default
    second = Organization.default
    assert_equal first.id, second.id
  end

  # === FriendlyId ===

  test "generates slug from name" do
    org = Organization.new(name: "Test Organization")
    org.valid?
    assert_equal "test-organization", org.slug
  end
end
