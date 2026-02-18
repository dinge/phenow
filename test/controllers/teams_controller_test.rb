# frozen_string_literal: true

require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  # Disable all automatic fixture loading for this test
  self.use_transactional_tests = true

  # Override fixture class methods to disable them
  def self.fixtures(*args)
    # Do nothing - don't load fixtures
  end

  setup do
    # Create test data manually to avoid fixture issues
    @organization = Organization.create!(
      name: "Test Organization",
      slug: "test-org"
    )

    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      name: "Test User"
    )

    @team = Team.create!(
      organization: @organization,
      name: "Test Team",
      description: "A test team"
    )

    @other_team = Team.create!(
      organization: @organization,
      name: "Other Team",
      description: "Another test team"
    )

    # Create membership for current user
    Membership.create!(
      team: @team,
      user: @user,
      role: "owner"
    )

    # Sign in with explicit scope
    sign_in @user, scope: :user
  end

  # ============================================
  # INDEX ACTION
  # ============================================

  test "index lists current user's teams" do
    get teams_url
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "index only shows teams user belongs to" do
    get teams_url
    collection = assigns(:collection)

    # Marcus should see breeding_team (owner/admin) but not testing_team
    assert_includes collection, @team
    assert_not_includes collection, @other_team
  end

  test "index responds to html" do
    get teams_url
    assert_response :success
  end

  test "index responds to turbo_stream" do
    get teams_url, as: :turbo_stream
    assert_response :success
  end

  test "index paginates collection with pagy" do
    get teams_url
    assert_not_nil assigns(:pagy)
    assert_not_nil assigns(:collection)
  end

  # ============================================
  # SHOW ACTION (redirects to edit)
  # ============================================

  test "show redirects to edit" do
    get team_url(@team)
    assert_redirected_to edit_team_url(@team)
  end

  # ============================================
  # NEW ACTION
  # ============================================

  test "new assigns new team" do
    get new_team_url
    assert_response :success
    assert_not_nil assigns(:resource)
    assert assigns(:resource).new_record?
  end

  test "new assigns team to current organization" do
    get new_team_url
    team = assigns(:resource)
    assert_equal @organization, team.organization
  end

  # ============================================
  # CREATE ACTION
  # ============================================

  test "create with valid params creates team" do
    assert_difference("Team.count") do
      post teams_url, params: {
        team: {
          name: "New Team",
          description: "A new team for testing"
        }
      }
    end
    assert_redirected_to teams_url
    assert_equal "Created successfully.", flash[:notice]
  end

  test "create associates team with current organization" do
    post teams_url, params: {
      team: {
        name: "New Team",
        description: "Testing org association"
      }
    }

    new_team = Team.order(:created_at).last
    assert_equal @organization, new_team.organization
  end

  test "create with valid params creates owner membership for current user" do
    assert_difference(["Team.count", "Membership.count"], 1) do
      post teams_url, params: {
        team: {
          name: "New Team",
          description: "Testing membership creation"
        }
      }
    end

    new_team = Team.order(:created_at).last
    membership = new_team.memberships.find_by(user: @user)

    assert_not_nil membership
    assert_equal "owner", membership.role
  end

  test "create with invalid params renders new" do
    assert_no_difference("Team.count") do
      post teams_url, params: {
        team: { name: "" }  # Invalid - name required
      }
    end
    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT ACTION
  # ============================================

  test "edit assigns team" do
    get edit_team_url(@team)
    assert_response :success
    assert_equal @team, assigns(:resource)
  end

  test "edit sets @team for sidebar context" do
    get edit_team_url(@team)
    assert_equal @team, assigns(:team)
  end

  # ============================================
  # UPDATE ACTION
  # ============================================

  test "update with valid params updates team" do
    new_name = "Updated Team Name"
    patch team_url(@team), params: {
      team: { name: new_name }
    }
    assert_redirected_to teams_url
    assert_equal "Updated successfully.", flash[:notice]
    assert_equal new_name, @team.reload.name
  end

  test "update with invalid params renders edit" do
    patch team_url(@team), params: {
      team: { name: "" }  # Invalid
    }
    assert_response :unprocessable_entity
  end

  # ============================================
  # DESTROY ACTION
  # ============================================

  test "destroy deletes team" do
    assert_difference("Team.count", -1) do
      delete team_url(@team)
    end
    assert_redirected_to teams_url
    assert_equal "Deleted successfully.", flash[:notice]
  end

  test "destroy deletes associated memberships" do
    team_to_delete = @team
    memberships_count = team_to_delete.memberships.count

    assert_difference("Membership.count", -memberships_count) do
      delete team_url(team_to_delete)
    end
  end

  # ============================================
  # SCOPING
  # ============================================

  test "cannot access teams from other organizations" do
    # Create another organization and team
    other_org = Organization.create!(
      name: "Other Organization",
      slug: "other-org"
    )

    other_org_team = Team.create!(
      organization: other_org,
      name: "Other Org Team",
      description: "Team from another org"
    )

    get team_url(other_org_team)
    assert_response :not_found
  end

  test "cannot edit teams user is not member of" do
    # Create another user who is not a member of @other_team
    jake = User.create!(
      email: "jake@example.com",
      password: "password123",
      name: "Jake User"
    )

    sign_out :user
    sign_in jake, scope: :user

    get edit_team_url(@other_team)
    assert_response :not_found
  end

  # ============================================
  # SEARCHING
  # ============================================

  test "search filters teams by name" do
    get teams_url, params: { q: "Test" }
    assert_response :success

    collection = assigns(:collection)
    assert collection.any?
    assert collection.all? { |t| t.name.include?("Test") }
  end

  test "search filters teams by description" do
    get teams_url, params: { q: "test team" }
    assert_response :success

    collection = assigns(:collection)
    assert collection.any?
  end

  test "search returns empty when no matches" do
    get teams_url, params: { q: "nonexistent team name xyz123" }
    assert_response :success

    collection = assigns(:collection)
    assert_empty collection
  end

  test "index without search returns all user teams" do
    get teams_url
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  # ============================================
  # SORTING
  # ============================================

  test "sort by name ascending" do
    get teams_url, params: { sort: "name", dir: "asc" }
    assert_response :success
  end

  test "sort by name descending" do
    get teams_url, params: { sort: "name", dir: "desc" }
    assert_response :success
  end

  test "sort by created_at" do
    get teams_url, params: { sort: "created_at", dir: "desc" }
    assert_response :success
  end

  # ============================================
  # FRIENDLY ID
  # ============================================

  test "can access team by slug" do
    get team_url(@team.slug)
    assert_redirected_to edit_team_url(@team)
  end

  test "can edit team by slug" do
    get edit_team_url(@team.slug)
    assert_response :success
  end

  # ============================================
  # CONTEXT SETTING
  # ============================================

  test "sets @team for sidebar in edit action" do
    get edit_team_url(@team)
    assert_equal @team, assigns(:team)
  end

  test "sets @team for sidebar in update action when invalid" do
    patch team_url(@team), params: {
      team: { name: "" }
    }
    assert_response :unprocessable_entity
    assert_equal @team, assigns(:team)
  end
end
