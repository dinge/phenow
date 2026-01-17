# frozen_string_literal: true

require "test_helper"

class SelectionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :organizations, :teams, :memberships, :projects, :strains, :plants, :selections

  setup do
    @user = users(:marcus)
    @team = teams(:breeding_team)
    @project = projects(:gmo_zkittlez_hunt)
    @plant = plants(:plant_1)
    @selection = selections(:plant_1_keeper)
    sign_in @user
  end

  # ============================================
  # INDEX - Nested under Plant
  # ============================================

  test "should get index for plant" do
    get team_project_plant_selections_url(@team, @project, @plant)
    assert_response :success
    assert_select "h1", text: /selections/i
  end

  test "index should display selections for plant" do
    get team_project_plant_selections_url(@team, @project, @plant)
    assert_response :success

    # Should show selection for this plant
    assert_select "tr##{dom_id(@selection)}"
    assert_select "td", text: "Breeding Mother"
  end

  test "index should not show selections from other plants" do
    other_selection = selections(:plant_2_cull) # From different plant
    get team_project_plant_selections_url(@team, @project, @plant)
    assert_response :success

    # Should NOT show selections from other plants
    assert_select "tr##{dom_id(other_selection)}", count: 0
  end

  test "index should filter by decision" do
    # Create a plant with multiple selection types
    plant_4 = plants(:plant_4)

    get team_project_plant_selections_url(@team, @project, plant_4, decision: "keep")
    assert_response :success

    # Should show keep selections
    assert_select "tr##{dom_id(selections(:plant_4_keeper))}"
  end

  test "index should search by reasoning" do
    get team_project_plant_selections_url(@team, @project, @plant, q: "Outstanding")
    assert_response :success

    # Should find selection with "Outstanding" in reasoning
    assert_select "tr##{dom_id(@selection)}"
  end

  # ============================================
  # NEW
  # ============================================

  test "should get new for plant" do
    get new_team_project_plant_selection_url(@team, @project, @plant)
    assert_response :success
    assert_select "h2", text: /new selection/i
  end

  test "new should display form fields" do
    get new_team_project_plant_selection_url(@team, @project, @plant)
    assert_response :success

    assert_select "form" do
      assert_select "select[name='selection[decision]']"
      assert_select "textarea[name='selection[reasoning]']"
      assert_select "input[name='selection[selected_at]']"
      assert_select "input[name='selection[score]']"
    end
  end

  # ============================================
  # CREATE
  # ============================================

  test "should create selection" do
    plant_3 = plants(:plant_3) # No selection yet

    assert_difference("Selection.count") do
      post team_project_plant_selections_url(@team, @project, plant_3), params: {
        selection: {
          decision: "keep",
          reasoning: "Excellent yield and terpene profile",
          selected_at: Time.current,
          score: 8.5
        }
      }
    end

    assert_redirected_to team_project_plant_selections_path(@team, @project, plant_3)
    assert_equal "Created successfully.", flash[:notice]
  end

  test "create should set selected_by to current user" do
    plant_3 = plants(:plant_3)

    post team_project_plant_selections_url(@team, @project, plant_3), params: {
      selection: {
        decision: "keep",
        reasoning: "Good structure",
        selected_at: Time.current
      }
    }

    selection = Selection.last
    assert_equal @user, selection.selected_by
  end

  test "create should update plant status to keeper for keep decision" do
    plant_3 = plants(:plant_3)
    assert_equal "active", plant_3.status

    post team_project_plant_selections_url(@team, @project, plant_3), params: {
      selection: {
        decision: "keep",
        reasoning: "Keeper quality",
        selected_at: Time.current
      }
    }

    plant_3.reload
    assert_equal "keeper", plant_3.status
  end

  test "create should update plant status to culled for cull decision" do
    plant_3 = plants(:plant_3)
    assert_equal "active", plant_3.status

    post team_project_plant_selections_url(@team, @project, plant_3), params: {
      selection: {
        decision: "cull",
        reasoning: "Weak vigor",
        selected_at: Time.current
      }
    }

    plant_3.reload
    assert_equal "culled", plant_3.status
  end

  test "should not create selection without reasoning" do
    plant_3 = plants(:plant_3)

    assert_no_difference("Selection.count") do
      post team_project_plant_selections_url(@team, @project, plant_3), params: {
        selection: {
          decision: "keep",
          reasoning: "" # Required field
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create selection without decision" do
    plant_3 = plants(:plant_3)

    assert_no_difference("Selection.count") do
      post team_project_plant_selections_url(@team, @project, plant_3), params: {
        selection: {
          decision: "",
          reasoning: "Some reasoning"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create selection with invalid decision" do
    plant_3 = plants(:plant_3)

    assert_no_difference("Selection.count") do
      post team_project_plant_selections_url(@team, @project, plant_3), params: {
        selection: {
          decision: "invalid_decision",
          reasoning: "Some reasoning"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT - Shallow route
  # ============================================

  test "should get edit" do
    get edit_selection_url(@selection)
    assert_response :success
    assert_select "h2", text: /edit selection/i
  end

  test "edit should pre-populate form fields" do
    get edit_selection_url(@selection)
    assert_response :success

    assert_select "form" do
      assert_select "select[name='selection[decision]'] option[selected][value=?]", @selection.decision
      assert_select "textarea[name='selection[reasoning]']", text: /#{@selection.reasoning.split.first}/
    end
  end

  # ============================================
  # UPDATE - Shallow route
  # ============================================

  test "should update selection" do
    new_reasoning = "Updated reasoning for keeper decision"
    patch selection_url(@selection), params: {
      selection: {
        reasoning: new_reasoning
      }
    }

    assert_redirected_to team_project_plant_selections_path(@selection.plant.project.team, @selection.plant.project, @selection.plant)
    assert_equal "Updated successfully.", flash[:notice]

    @selection.reload
    assert_equal new_reasoning, @selection.reasoning
  end

  test "should update selection decision" do
    patch selection_url(@selection), params: {
      selection: {
        decision: "keep",
        reasoning: "Downgraded from breeding mother to keeper"
      }
    }

    assert_redirected_to team_project_plant_selections_path(@selection.plant.project.team, @selection.plant.project, @selection.plant)

    @selection.reload
    assert_equal "keep", @selection.decision
  end

  test "should not update selection with invalid data" do
    patch selection_url(@selection), params: {
      selection: { reasoning: "" } # Required field
    }

    assert_response :unprocessable_entity

    @selection.reload
    assert_not_empty @selection.reasoning
  end

  test "should not update selection with invalid decision" do
    patch selection_url(@selection), params: {
      selection: { decision: "invalid_decision" }
    }

    assert_response :unprocessable_entity

    @selection.reload
    assert_equal "breeding_mother", @selection.decision
  end

  # ============================================
  # DESTROY - Shallow route
  # ============================================

  test "should destroy selection" do
    assert_difference("Selection.count", -1) do
      delete selection_url(@selection)
    end

    assert_redirected_to team_project_plant_selections_path(@selection.plant.project.team, @selection.plant.project, @selection.plant)
    assert_equal "Deleted successfully.", flash[:notice]
  end

  # ============================================
  # SCOPING & AUTHORIZATION
  # ============================================

  test "should only access selections from specified plant" do
    other_plant = plants(:plant_2)
    other_selection = selections(:plant_2_cull)

    # Try to access selection list for different plant
    get team_project_plant_selections_url(@team, @project, other_plant)
    assert_response :success

    # Should not show selections from first plant
    assert_select "tr##{dom_id(@selection)}", count: 0
    # Should show selections from other plant
    assert_select "tr##{dom_id(other_selection)}"
  end

  test "should require authentication" do
    sign_out @user

    get team_project_plant_selections_url(@team, @project, @plant)
    assert_redirected_to new_user_session_path
  end

  # ============================================
  # SIDEBAR CONTEXT
  # ============================================

  test "index should set plant for sidebar context" do
    get team_project_plant_selections_url(@team, @project, @plant)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end

  test "new should set plant for sidebar context" do
    get new_team_project_plant_selection_url(@team, @project, @plant)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end

  test "edit should set plant for sidebar context" do
    get edit_selection_url(@selection)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end
end
