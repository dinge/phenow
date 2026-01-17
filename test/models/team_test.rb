# frozen_string_literal: true

require "test_helper"

class TeamTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid team" do
    assert_valid teams(:breeding_team)
  end

  test "requires name" do
    team = Team.new(organization: organizations(:exotic_genetics))
    assert_invalid team, :name
  end

  test "requires organization" do
    team = Team.new(name: "Orphan Team")
    assert_invalid team, :organization
  end

  test "requires unique slug within organization" do
    duplicate = Team.new(
      organization: organizations(:exotic_genetics),
      name: "Different Name",
      slug: teams(:breeding_team).slug
    )
    assert_invalid duplicate, :slug
  end

  test "allows same slug in different organizations" do
    team = Team.new(
      organization: organizations(:west_coast_seeds),
      name: "Breeding Team",
      slug: "breeding-team"
    )
    assert_valid team
  end

  # === Associations ===

  test "belongs to organization" do
    assert_equal organizations(:exotic_genetics), teams(:breeding_team).organization
  end

  test "has many memberships" do
    assert_respond_to teams(:breeding_team), :memberships
    assert teams(:breeding_team).memberships.count > 0
  end

  test "has many users through memberships" do
    assert_respond_to teams(:breeding_team), :users
    assert_includes teams(:breeding_team).users, users(:marcus)
  end

  test "has many projects" do
    assert_respond_to teams(:breeding_team), :projects
    assert teams(:breeding_team).projects.count > 0
  end
end
