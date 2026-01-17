# frozen_string_literal: true

require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid project" do
    assert_valid projects(:gmo_zkittlez_hunt)
  end

  test "requires name" do
    project = Project.new(
      team: teams(:breeding_team),
      strain: strains(:gmo_x_zkittlez)
    )
    assert_invalid project, :name
  end

  test "requires team" do
    project = Project.new(
      name: "Test Project",
      strain: strains(:gmo_x_zkittlez)
    )
    assert_invalid project, :team
  end

  test "requires unique slug within team" do
    duplicate = Project.new(
      team: teams(:breeding_team),
      strain: strains(:gmo_x_zkittlez),
      name: "Different Name",
      slug: projects(:gmo_zkittlez_hunt).slug
    )
    assert_invalid duplicate, :slug
  end

  test "validates status inclusion" do
    project = projects(:gmo_zkittlez_hunt)
    project.status = "invalid_status"
    assert_invalid project, :status
  end

  # === Associations ===

  test "belongs to team" do
    assert_equal teams(:breeding_team), projects(:gmo_zkittlez_hunt).team
  end

  test "belongs to strain" do
    assert_equal strains(:gmo_x_zkittlez), projects(:gmo_zkittlez_hunt).strain
  end

  test "has many project goals" do
    assert_respond_to projects(:gmo_zkittlez_hunt), :project_goals
    assert projects(:gmo_zkittlez_hunt).project_goals.count > 0
  end

  test "has many plants" do
    assert_respond_to projects(:gmo_zkittlez_hunt), :plants
    assert projects(:gmo_zkittlez_hunt).plants.count > 0
  end

  # === Scopes ===

  test "active returns active projects" do
    active = Project.active
    assert active.all? { |p| p.status == "active" }
    assert_includes active, projects(:gmo_zkittlez_hunt)
  end

  test "completed returns completed projects" do
    completed = Project.completed
    assert completed.all? { |p| p.status == "completed" }
    assert_includes completed, projects(:purple_punch_preservation)
  end

  # === Instance Methods ===

  test "active? returns true for active status" do
    assert projects(:gmo_zkittlez_hunt).active?
    assert_not projects(:purple_punch_preservation).active?
  end

  test "completed? returns true for completed status" do
    assert projects(:purple_punch_preservation).completed?
    assert_not projects(:gmo_zkittlez_hunt).completed?
  end

  test "organization returns team's organization" do
    assert_equal organizations(:exotic_genetics), projects(:gmo_zkittlez_hunt).organization
  end
end
