# frozen_string_literal: true

require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid membership" do
    assert_valid memberships(:marcus_breeding)
  end

  test "requires team" do
    membership = Membership.new(user: users(:marcus), role: "member")
    assert_invalid membership, :team
  end

  test "requires user" do
    membership = Membership.new(team: teams(:breeding_team), role: "member")
    assert_invalid membership, :user
  end

  test "requires role" do
    membership = Membership.new(team: teams(:breeding_team), user: users(:marcus))
    membership.role = nil
    assert_invalid membership, :role
  end

  test "requires valid role" do
    membership = memberships(:marcus_breeding)
    membership.role = "invalid_role"
    assert_invalid membership, :role
  end

  test "user can only have one membership per team" do
    duplicate = Membership.new(
      team: teams(:breeding_team),
      user: users(:marcus),
      role: "member"
    )
    assert_invalid duplicate, :user_id
  end

  # === Associations ===

  test "belongs to team" do
    assert_equal teams(:breeding_team), memberships(:marcus_breeding).team
  end

  test "belongs to user" do
    assert_equal users(:marcus), memberships(:marcus_breeding).user
  end

  # === Role Methods ===

  test "owner? returns true for owner role" do
    assert memberships(:marcus_breeding).owner?
    assert_not memberships(:sarah_breeding).owner?
  end

  test "admin? returns true for admin role" do
    assert memberships(:sarah_breeding).admin?
    assert_not memberships(:marcus_breeding).admin?
  end

  test "member? returns true for member role" do
    assert memberships(:jake_testing).member?
  end

  test "viewer? returns true for viewer role" do
    assert memberships(:emily_breeding).viewer?
  end

  test "can_edit? returns true for owner and admin" do
    assert memberships(:marcus_breeding).can_edit?
    assert memberships(:sarah_breeding).can_edit?
    assert_not memberships(:jake_breeding).can_edit?
    assert_not memberships(:emily_breeding).can_edit?
  end
end
