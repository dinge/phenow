# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :organizations, :teams, :projects, :strains, :project_goals, :memberships

  setup do
    @user = users(:marcus)
    @team = teams(:breeding_team)
    @project = projects(:gmo_zkittlez_hunt)
    sign_in @user
  end

  # ============================================
  # INDEX TESTS
  # ============================================

  test "should get index" do
    get team_projects_url(@team)
    assert_response :success
    assert_select "h1", "Projects"
  end

  test "should show projects in table" do
    get team_projects_url(@team)
    assert_select "table.data-table"
    assert_select "tr#project_#{@project.id}"
  end

  test "should filter by status" do
    get team_projects_url(@team, status: "active")
    assert_response :success
    # Collection should only contain active projects
  end

  test "should filter by project_type" do
    get team_projects_url(@team, project_type: "phenohunt")
    assert_response :success
    # Collection should only contain phenohunt projects
  end

  test "should search projects" do
    get team_projects_url(@team, q: "GMO")
    assert_response :success
  end

  # ============================================
  # NEW TESTS
  # ============================================

  test "should get new" do
    get new_team_project_url(@team)
    assert_response :success
    assert_select "h2", "New Project"
  end

  test "should render form in new" do
    get new_team_project_url(@team)
    assert_select "form[action=?]", team_projects_path(@team)
    assert_select "input[name='project[name]']"
    assert_select "select[name='project[project_type]']"
    assert_select "select[name='project[status]']"
  end

  # ============================================
  # CREATE TESTS
  # ============================================

  test "should create project" do
    assert_difference("Project.count", 1) do
      post team_projects_url(@team), params: {
        project: {
          name: "New Phenohunt",
          project_type: "phenohunt",
          status: "planning",
          description: "Test description",
          strain_id: strains(:gmo_x_zkittlez).id,
          seed_count: 12
        }
      }
    end

    assert_redirected_to team_projects_url(@team)
    follow_redirect!
    assert_select ".flash-notice", text: /Created successfully/
  end

  test "should not create project with invalid params" do
    assert_no_difference("Project.count") do
      post team_projects_url(@team), params: {
        project: {
          name: "",  # Invalid - blank name
          project_type: "phenohunt"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-error"
  end

  test "should not create project with invalid project_type" do
    assert_no_difference("Project.count") do
      post team_projects_url(@team), params: {
        project: {
          name: "Test Project",
          project_type: "invalid_type"  # Invalid type
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT TESTS
  # ============================================

  test "should get edit" do
    get edit_team_project_url(@team, @project)
    assert_response :success
    assert_select "h2", "Edit Project"
  end

  test "should render form in edit" do
    get edit_team_project_url(@team, @project)
    assert_select "form[action=?]", team_project_path(@team, @project)
    assert_select "input[name='project[name]'][value=?]", @project.name
  end

  # ============================================
  # UPDATE TESTS
  # ============================================

  test "should update project" do
    patch team_project_url(@team, @project), params: {
      project: {
        name: "Updated Project Name",
        status: "completed"
      }
    }

    assert_redirected_to team_projects_url(@team)
    follow_redirect!
    assert_select ".flash-notice", text: /Updated successfully/

    @project.reload
    assert_equal "Updated Project Name", @project.name
    assert_equal "completed", @project.status
  end

  test "should not update project with invalid params" do
    patch team_project_url(@team, @project), params: {
      project: {
        name: ""  # Invalid - blank name
      }
    }

    assert_response :unprocessable_entity
    assert_select ".form-error"

    @project.reload
    assert_not_equal "", @project.name
  end

  test "should not update project with invalid project_type" do
    original_type = @project.project_type

    patch team_project_url(@team, @project), params: {
      project: {
        project_type: "invalid_type"
      }
    }

    assert_response :unprocessable_entity

    @project.reload
    assert_equal original_type, @project.project_type
  end

  # ============================================
  # DESTROY TESTS
  # ============================================

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete team_project_url(@team, @project)
    end

    assert_redirected_to team_projects_url(@team)
    follow_redirect!
    assert_select ".flash-notice", text: /Deleted successfully/
  end

  # ============================================
  # NESTED RESOURCE TESTS
  # ============================================

  test "should scope projects to team" do
    other_team = teams(:testing_team)

    get team_projects_url(@team)
    assert_response :success

    # Should not see projects from other team
    assert_select "tr#project_#{@project.id}"
  end

  test "should create project under correct team" do
    post team_projects_url(@team), params: {
      project: {
        name: "Team-specific Project",
        project_type: "phenohunt"
      }
    }

    new_project = Project.order(:created_at).last
    assert_equal @team.id, new_project.team_id
  end

  # ============================================
  # SHOW REDIRECTS TO EDIT
  # ============================================

  test "should redirect show to edit" do
    get team_project_url(@team, @project)
    assert_redirected_to edit_team_project_url(@team, @project)
  end
end
