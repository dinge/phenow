# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid user" do
    assert_valid users(:marcus)
  end

  test "requires email" do
    user = User.new(name: "Test User", password: "password123")
    assert_invalid user, :email
  end

  test "requires unique email" do
    duplicate = User.new(
      email: users(:marcus).email,
      password: "password123",
      name: "Duplicate"
    )
    assert_invalid duplicate, :email
  end

  test "requires valid email format" do
    user = users(:marcus)
    user.email = "not-an-email"
    assert_invalid user, :email
  end

  # === Associations ===

  test "has many memberships" do
    assert_respond_to users(:marcus), :memberships
  end

  test "has many teams through memberships" do
    assert_respond_to users(:marcus), :teams
    assert_includes users(:marcus).teams, teams(:breeding_team)
  end

  test "has many organizations through teams" do
    assert_respond_to users(:marcus), :organizations
  end

  test "has many observations" do
    assert_respond_to users(:marcus), :observations
    assert users(:marcus).observations.count > 0
  end

  test "has many selections" do
    assert_respond_to users(:marcus), :selections
  end

  test "has many comments" do
    assert_respond_to users(:sarah), :comments
  end

  # === Instance Methods ===

  test "full_name returns name" do
    assert_equal "Marcus Johnson", users(:marcus).name
  end
end
