# frozen_string_literal: true

require "test_helper"

class ProjectGoalTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid project goal" do
    assert_valid project_goals(:gmo_z_thc_goal)
  end

  test "requires project" do
    goal = ProjectGoal.new(description: "Test Goal", priority: 1)
    assert_invalid goal, :project
  end

  test "requires description" do
    goal = ProjectGoal.new(project: projects(:gmo_zkittlez_hunt), priority: 1)
    assert_invalid goal, :description
  end

  test "requires priority" do
    goal = ProjectGoal.new(project: projects(:gmo_zkittlez_hunt), description: "Test")
    assert_invalid goal, :priority
  end

  test "priority must be positive" do
    goal = project_goals(:gmo_z_thc_goal)
    goal.priority = 0
    assert_invalid goal, :priority
  end

  # === Associations ===

  test "belongs to project" do
    assert_equal projects(:gmo_zkittlez_hunt), project_goals(:gmo_z_thc_goal).project
  end

  # === Scopes ===

  test "by_priority returns goals ordered by priority" do
    goals = ProjectGoal.by_priority
    priorities = goals.map(&:priority)
    assert_equal priorities, priorities.sort
  end

  # === Instance Methods ===

  test "team returns project's team" do
    assert_equal teams(:breeding_team), project_goals(:gmo_z_thc_goal).team
  end

  test "organization returns project's organization" do
    assert_equal organizations(:exotic_genetics), project_goals(:gmo_z_thc_goal).organization
  end
end
