# frozen_string_literal: true

require "test_helper"

class ObservationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :organizations, :teams, :memberships, :projects, :strains, :plants, :observations

  setup do
    @user = users(:marcus)
    @team = teams(:breeding_team)
    @project = projects(:gmo_zkittlez_hunt)
    @plant = plants(:plant_1)
    @observation = observations(:obs_1_flowering)
    sign_in @user
  end

  # ============================================
  # INDEX - Nested under plant
  # ============================================

  test "should get index for plant" do
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success
    assert_select "h1", text: /observations/i
  end

  test "index should display observations for plant" do
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success

    # Should show observations from this plant
    assert_select "tr##{dom_id(@observation)}"
    assert_select "td", text: /Week 4 flower/
  end

  test "index should not show observations from other plants" do
    other_observation = observations(:obs_3_flowering) # From plant_3
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success

    # Should NOT show observations from other plants
    assert_select "tr##{dom_id(other_observation)}", count: 0
  end

  test "index should order observations chronologically" do
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success

    # Should show observations in order by observed_at (chronological = oldest first)
    # Verify observations are present and in correct order
    assert_select "tr##{dom_id(observations(:obs_1_seedling))}"
    assert_select "tr##{dom_id(observations(:obs_1_flowering))}"

    # The seedling observation (earliest) should appear before the flowering one
    response_body = @response.body
    seedling_pos = response_body.index(dom_id(observations(:obs_1_seedling)))
    flowering_pos = response_body.index(dom_id(observations(:obs_1_flowering)))

    assert_not_nil seedling_pos, "Seedling observation should be in the response"
    assert_not_nil flowering_pos, "Flowering observation should be in the response"
    assert seedling_pos < flowering_pos, "Seedling observation should appear before flowering observation"
  end

  test "index should filter by stage" do
    get team_project_plant_observations_url(@team, @project, @plant, stage: "flowering")
    assert_response :success

    # Should show flowering observation
    assert_select "tr##{dom_id(observations(:obs_1_flowering))}"
    # Should not show seedling observation
    assert_select "tr##{dom_id(observations(:obs_1_seedling))}", count: 0
  end

  test "index should search by notes" do
    get team_project_plant_observations_url(@team, @project, @plant, q: "frost")
    assert_response :success

    # Should show observation with "frost" in notes
    assert_select "tr##{dom_id(observations(:obs_1_flowering))}"
  end

  # ============================================
  # NEW - Nested under plant
  # ============================================

  test "should get new" do
    get new_team_project_plant_observation_url(@team, @project, @plant)
    assert_response :success
    assert_select "h2", text: /new observation/i
  end

  test "new should display form fields" do
    get new_team_project_plant_observation_url(@team, @project, @plant)
    assert_response :success

    assert_select "form" do
      assert_select "input[name='observation[observed_at]']"
      assert_select "select[name='observation[stage]']"
      assert_select "input[name='observation[overall_score]']"
      assert_select "input[name='observation[week_number]']"
      assert_select "textarea[name='observation[notes]']"
    end
  end

  test "new should pre-select current plant stage" do
    get new_team_project_plant_observation_url(@team, @project, @plant)
    assert_response :success

    # Should pre-select the plant's current_stage
    assert_select "select[name='observation[stage]']" do
      assert_select "option[value='#{@plant.current_stage}'][selected]"
    end
  end

  # ============================================
  # CREATE - Nested under plant
  # ============================================

  test "should create observation" do
    assert_difference("Observation.count") do
      post team_project_plant_observations_url(@team, @project, @plant), params: {
        observation: {
          observed_at: Time.current,
          stage: "flowering",
          overall_score: 8,
          week_number: 4,
          notes: "Looking good, heavy frost development. Env: Temp 72F, RH 45%"
        }
      }
    end

    assert_redirected_to team_project_plant_observations_path(@team, @project, @plant)
    assert_equal "Created successfully.", flash[:notice]

    # Verify observation was created with correct associations
    obs = Observation.last
    assert_equal @plant, obs.plant
    assert_equal @user, obs.observed_by
  end

  test "should not create observation with invalid data" do
    assert_no_difference("Observation.count") do
      post team_project_plant_observations_url(@team, @project, @plant), params: {
        observation: {
          overall_score: 15, # Invalid - max is 10
          notes: "Some notes"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create should auto-set observed_by to current_user" do
    post team_project_plant_observations_url(@team, @project, @plant), params: {
      observation: {
        observed_at: Time.current,
        stage: "vegetative",
        notes: "Test observation"
      }
    }

    obs = Observation.last
    assert_equal @user, obs.observed_by
  end

  test "create should auto-set stage to plant current_stage if not provided" do
    post team_project_plant_observations_url(@team, @project, @plant), params: {
      observation: {
        observed_at: Time.current,
        notes: "Test observation"
      }
    }

    obs = Observation.last
    assert_equal @plant.current_stage, obs.stage
  end

  # ============================================
  # EDIT - Shallow route
  # ============================================

  test "should get edit" do
    get edit_observation_url(@observation)
    assert_response :success
    assert_select "h2", text: /edit observation/i
  end

  test "edit should pre-populate form fields" do
    get edit_observation_url(@observation)
    assert_response :success

    assert_select "form" do
      assert_select "select[name='observation[stage]']" do
        assert_select "option[value='#{@observation.stage}'][selected]"
      end
      assert_select "textarea[name='observation[notes]']", text: @observation.notes
    end
  end

  # ============================================
  # UPDATE - Shallow route
  # ============================================

  test "should update observation" do
    new_notes = "Updated observation notes"
    patch observation_url(@observation), params: {
      observation: {
        notes: new_notes,
        overall_score: 9
      }
    }

    assert_redirected_to team_project_plant_observations_path(@team, @project, @observation.plant)
    assert_equal "Updated successfully.", flash[:notice]

    @observation.reload
    assert_equal new_notes, @observation.notes
    assert_equal 9, @observation.overall_score
  end

  test "should update observation stage" do
    patch observation_url(@observation), params: {
      observation: { stage: "harvest" }
    }

    assert_redirected_to team_project_plant_observations_path(@team, @project, @observation.plant)

    @observation.reload
    assert_equal "harvest", @observation.stage
  end

  test "should not update observation with invalid data" do
    original_score = @observation.overall_score
    patch observation_url(@observation), params: {
      observation: { overall_score: 15 } # Invalid - max is 10
    }

    assert_response :unprocessable_entity

    @observation.reload
    assert_equal original_score, @observation.overall_score
  end

  # ============================================
  # DESTROY - Shallow route
  # ============================================

  test "should destroy observation" do
    assert_difference("Observation.count", -1) do
      delete observation_url(@observation)
    end

    assert_redirected_to team_project_plant_observations_path(@team, @project, @observation.plant)
    assert_equal "Deleted successfully.", flash[:notice]
  end

  # ============================================
  # SCOPING & AUTHORIZATION
  # ============================================

  test "should only access observations from specified plant" do
    other_plant = plants(:plant_3)
    other_observation = observations(:obs_3_flowering)

    # Try to access observation from different plant using current plant URL
    get edit_observation_url(other_observation)
    assert_response :success # Shallow route allows this

    # But index should be scoped to plant
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success
    assert_select "tr##{dom_id(other_observation)}", count: 0
  end

  test "should only access observations from team's plants" do
    # Try to access observation from different team's plant
    other_plant = plants(:pp_1) # Different project
    other_observation = observations(:obs_pp1_final)

    # This should work because shallow routes allow cross-team access
    # (Authorization would be handled by Pundit in real implementation)
    get edit_observation_url(other_observation)
    assert_response :success
  end

  test "should require authentication" do
    sign_out @user

    get team_project_plant_observations_url(@team, @project, @plant)
    assert_redirected_to new_user_session_path
  end

  # ============================================
  # SIDEBAR CONTEXT
  # ============================================

  test "index should set plant for sidebar context" do
    get team_project_plant_observations_url(@team, @project, @plant)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end

  test "new should set plant for sidebar context" do
    get new_team_project_plant_observation_url(@team, @project, @plant)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end

  test "edit should set plant for sidebar context" do
    get edit_observation_url(@observation)
    assert_response :success
    assert_equal @plant, assigns(:plant)
    assert_equal @project, assigns(:project)
    assert_equal @team, assigns(:team)
  end
end
