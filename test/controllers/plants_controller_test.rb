# frozen_string_literal: true

require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :organizations, :teams, :memberships, :projects, :strains, :plants

  setup do
    @user = users(:marcus)
    @team = teams(:breeding_team)
    @project = projects(:gmo_zkittlez_hunt)
    @plant = plants(:plant_1)
    sign_in @user
  end

  # ============================================
  # INDEX
  # ============================================

  test "should get index" do
    get team_project_plants_url(@team, @project)
    assert_response :success
    assert_select "h1", text: /plants/i
  end

  test "index should display plants for project" do
    get team_project_plants_url(@team, @project)
    assert_response :success

    # Should show plants from this project
    assert_select "tr##{dom_id(@plant)}"
    assert_select "td", text: @plant.identifier
  end

  test "index should not show plants from other projects" do
    other_plant = plants(:pp_1) # From different project
    get team_project_plants_url(@team, @project)
    assert_response :success

    # Should NOT show plants from other projects
    assert_select "tr##{dom_id(other_plant)}", count: 0
  end

  test "index should filter by status" do
    get team_project_plants_url(@team, @project, status: "keeper")
    assert_response :success

    # Should show keeper plants
    assert_select "tr##{dom_id(plants(:plant_1))}"
    # Should not show active plants
    assert_select "tr##{dom_id(plants(:plant_3))}", count: 0
  end

  test "index should filter by current_stage" do
    get team_project_plants_url(@team, @project, stage: "flowering")
    assert_response :success

    # Should show flowering plants
    assert_select "tr##{dom_id(plants(:plant_3))}"
    # Should not show testing stage plants
    assert_select "tr##{dom_id(plants(:plant_1))}", count: 0
  end

  test "index should filter by strain_id" do
    strain = strains(:gmo_x_zkittlez)
    get team_project_plants_url(@team, @project, strain_id: strain.id)
    assert_response :success

    # Should show plants of this strain
    assert_select "tr##{dom_id(@plant)}"
  end

  test "index should search by identifier or name" do
    get team_project_plants_url(@team, @project, q: "Gassy")
    assert_response :success

    # Should show plant with "Gassy Grape" name
    assert_select "tr##{dom_id(plants(:plant_1))}"
  end

  # ============================================
  # NEW
  # ============================================

  test "should get new" do
    get new_team_project_plant_url(@team, @project)
    assert_response :success
    assert_select "h2", text: /new plant/i
  end

  test "new should display form fields" do
    get new_team_project_plant_url(@team, @project)
    assert_response :success

    assert_select "form" do
      assert_select "input[name='plant[identifier]']"
      assert_select "input[name='plant[name]']"
      assert_select "select[name='plant[strain_id]']"
      assert_select "select[name='plant[source_type]']"
      assert_select "select[name='plant[sex]']"
      assert_select "select[name='plant[current_stage]']"
      assert_select "select[name='plant[status]']"
    end
  end

  # ============================================
  # CREATE
  # ============================================

  test "should create plant" do
    assert_difference("Plant.count") do
      post team_project_plants_url(@team, @project), params: {
        plant: {
          identifier: "#99",
          name: "Test Plant",
          strain_id: strains(:gmo_x_zkittlez).id,
          source_type: "seed",
          sex: "unknown",
          current_stage: "germination",
          status: "active",
          germination_date: Date.current,
          notes: "Test notes"
        }
      }
    end

    assert_redirected_to team_project_plants_path(@team, @project)
    assert_equal "Created successfully.", flash[:notice]
  end

  test "should not create plant with invalid data" do
    assert_no_difference("Plant.count") do
      post team_project_plants_url(@team, @project), params: {
        plant: {
          identifier: "", # Required field
          source_type: "seed"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create plant with duplicate identifier in same project" do
    assert_no_difference("Plant.count") do
      post team_project_plants_url(@team, @project), params: {
        plant: {
          identifier: @plant.identifier, # Duplicate
          source_type: "seed"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT
  # ============================================

  test "should get edit" do
    get edit_team_project_plant_url(@team, @project, @plant)
    assert_response :success
    assert_select "h2", text: /edit plant/i
  end

  test "edit should pre-populate form fields" do
    get edit_team_project_plant_url(@team, @project, @plant)
    assert_response :success

    assert_select "form" do
      assert_select "input[name='plant[identifier]'][value=?]", @plant.identifier
      assert_select "input[name='plant[name]'][value=?]", @plant.name
    end
  end

  # ============================================
  # UPDATE
  # ============================================

  test "should update plant" do
    new_name = "Updated Name"
    patch team_project_plant_url(@team, @project, @plant), params: {
      plant: {
        name: new_name,
        notes: "Updated notes"
      }
    }

    assert_redirected_to team_project_plants_path(@team, @project)
    assert_equal "Updated successfully.", flash[:notice]

    @plant.reload
    assert_equal new_name, @plant.name
  end

  test "should update plant stage" do
    patch team_project_plant_url(@team, @project, @plant), params: {
      plant: { current_stage: "drying" }
    }

    assert_redirected_to team_project_plants_path(@team, @project)

    @plant.reload
    assert_equal "drying", @plant.current_stage
  end

  test "should not update plant with invalid data" do
    patch team_project_plant_url(@team, @project, @plant), params: {
      plant: { identifier: "" } # Required field
    }

    assert_response :unprocessable_entity

    @plant.reload
    assert_not_empty @plant.identifier
  end

  # ============================================
  # DESTROY
  # ============================================

  test "should destroy plant" do
    assert_difference("Plant.count", -1) do
      delete team_project_plant_url(@team, @project, @plant)
    end

    assert_redirected_to team_project_plants_path(@team, @project)
    assert_equal "Deleted successfully.", flash[:notice]
  end

  # ============================================
  # SCOPING & AUTHORIZATION
  # ============================================

  test "should only access plants from specified project" do
    other_project = projects(:purple_punch_preservation)
    other_plant = plants(:pp_1)

    # Try to access plant from different project using current project URL
    get edit_team_project_plant_url(@team, @project, other_plant)
    assert_response :not_found
  end

  test "should require authentication" do
    sign_out @user

    get team_project_plants_url(@team, @project)
    assert_redirected_to new_user_session_path
  end
end
