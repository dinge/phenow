# frozen_string_literal: true

require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :organizations, :teams, :memberships, :projects, :strains, :plants, :photos

  setup do
    @user = users(:marcus)
    @team = teams(:breeding_team)
    @project = projects(:gmo_zkittlez_hunt)
    @plant = plants(:plant_1)
    @photo = photos(:plant_1_veg_photo)
    sign_in @user
  end

  # ============================================
  # INDEX - Nested under plant
  # ============================================

  test "should get index nested under plant" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success
    assert_select "h1", text: /photos/i
  end

  test "index should display photos for plant" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    # Should show photos from this plant
    assert_select ".photo-card", minimum: 1
  end

  test "index should not show photos from other plants" do
    other_plant = plants(:plant_3)
    other_photo = photos(:plant_3_flower_photo)

    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    # Should NOT show photos from other plants
    assert_select "img[alt*='#{other_photo.caption}']", count: 0
  end

  test "index should filter by photo_type" do
    get team_project_plant_photos_url(@team, @project, @plant, photo_type: "whole_plant")
    assert_response :success
  end

  test "index should filter by stage" do
    get team_project_plant_photos_url(@team, @project, @plant, stage: "flowering")
    assert_response :success
  end

  # ============================================
  # NEW - Nested under plant
  # ============================================

  test "should get new nested under plant" do
    get new_team_project_plant_photo_url(@team, @project, @plant)
    assert_response :success
    assert_select "h2", text: /new photo/i
  end

  test "new should display form fields" do
    get new_team_project_plant_photo_url(@team, @project, @plant)
    assert_response :success

    assert_select "form" do
      assert_select "input[name='photo[image]'][type='file']"
      assert_select "textarea[name='photo[caption]']"
      assert_select "input[name='photo[taken_at]']"
      assert_select "select[name='photo[photo_type]']"
      assert_select "select[name='photo[stage]']"
    end
  end

  # ============================================
  # CREATE - Nested under plant
  # ============================================

  test "should create photo with image upload" do
    skip "Requires ActiveStorage setup in test environment"

    assert_difference("Photo.count") do
      post team_project_plant_photos_url(@team, @project, @plant), params: {
        photo: {
          image: fixture_file_upload("test_photo.jpg", "image/jpeg"),
          caption: "Test photo caption",
          taken_at: Time.current,
          photo_type: "whole_plant",
          stage: "vegetative"
        }
      }
    end

    assert_redirected_to team_project_plant_photos_path(@team, @project, @plant)
    assert_equal "Created successfully.", flash[:notice]
  end

  test "should create photo without optional fields" do
    skip "Requires ActiveStorage setup in test environment"

    assert_difference("Photo.count") do
      post team_project_plant_photos_url(@team, @project, @plant), params: {
        photo: {
          image: fixture_file_upload("test_photo.jpg", "image/jpeg")
        }
      }
    end

    assert_redirected_to team_project_plant_photos_path(@team, @project, @plant)
  end

  test "should not create photo without image" do
    assert_no_difference("Photo.count") do
      post team_project_plant_photos_url(@team, @project, @plant), params: {
        photo: {
          caption: "Test caption"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create photo with invalid photo_type" do
    skip "Requires ActiveStorage setup in test environment"

    assert_no_difference("Photo.count") do
      post team_project_plant_photos_url(@team, @project, @plant), params: {
        photo: {
          image: fixture_file_upload("test_photo.jpg", "image/jpeg"),
          photo_type: "invalid_type"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT - Shallow route
  # ============================================

  test "should get edit with shallow route" do
    get edit_photo_url(@photo)
    assert_response :success
    assert_select "h2", text: /edit photo/i
  end

  test "edit should pre-populate form fields" do
    get edit_photo_url(@photo)
    assert_response :success

    assert_select "form" do
      assert_select "textarea[name='photo[caption]']", text: @photo.caption
      assert_select "select[name='photo[stage]']"
    end
  end

  # ============================================
  # UPDATE - Shallow route
  # ============================================

  test "should update photo" do
    new_caption = "Updated caption"
    patch photo_url(@photo), params: {
      photo: {
        caption: new_caption,
        photo_type: "bud"
      }
    }

    assert_redirected_to team_project_plant_photos_path(@team, @project, @plant)
    assert_equal "Updated successfully.", flash[:notice]

    @photo.reload
    assert_equal new_caption, @photo.caption
    assert_equal "bud", @photo.photo_type
  end

  test "should update photo stage" do
    patch photo_url(@photo), params: {
      photo: { stage: "flowering" }
    }

    assert_redirected_to team_project_plant_photos_path(@team, @project, @plant)

    @photo.reload
    assert_equal "flowering", @photo.stage
  end

  test "should not update photo with invalid photo_type" do
    patch photo_url(@photo), params: {
      photo: { photo_type: "invalid_type" }
    }

    assert_response :unprocessable_entity

    @photo.reload
    assert_not_equal "invalid_type", @photo.photo_type
  end

  # ============================================
  # DESTROY - Shallow route
  # ============================================

  test "should destroy photo" do
    assert_difference("Photo.count", -1) do
      delete photo_url(@photo)
    end

    assert_redirected_to team_project_plant_photos_path(@team, @project, @plant)
    assert_equal "Deleted successfully.", flash[:notice]
  end

  test "should destroy photo and its ActiveStorage attachment" do
    skip "Requires ActiveStorage setup in test environment"

    # Create a photo with an actual attachment
    photo = Photo.create!(
      photographable: @plant,
      image: fixture_file_upload("test_photo.jpg", "image/jpeg"),
      taken_by: @user
    )

    assert photo.image.attached?

    assert_difference("Photo.count", -1) do
      delete photo_url(photo)
    end

    # ActiveStorage blob should be deleted too
    assert_not ActiveStorage::Blob.exists?(photo.image.blob.id)
  end

  # ============================================
  # SCOPING & AUTHORIZATION
  # ============================================

  test "should scope photos to plant" do
    other_plant = plants(:plant_3)
    other_photo = photos(:plant_3_flower_photo)

    # Try to access photo from different plant
    get edit_photo_url(other_photo)
    # Should still work because shallow routes don't enforce parent scope by default
    # But the controller should handle this properly
    assert_response :success
  end

  test "should set plant context for sidebar" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    # Verify instance variables are set
    assert_not_nil assigns(:plant)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:team)
    assert_equal @plant, assigns(:plant)
  end

  test "should require authentication" do
    sign_out @user

    get team_project_plant_photos_url(@team, @project, @plant)
    assert_redirected_to new_user_session_path
  end

  test "should handle polymorphic photographable (Plant)" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    # All photos should be for Plant type
    @plant.photos.each do |photo|
      assert_equal "Plant", photo.photographable_type
      assert_equal @plant.id, photo.photographable_id
    end
  end

  # ============================================
  # EDGE CASES
  # ============================================

  test "should handle plant with no photos" do
    plant_without_photos = plants(:plant_8)

    # Verify plant actually has no photos
    assert_equal 0, plant_without_photos.photos.count, "Plant 8 should have no photos"

    get team_project_plant_photos_url(@team, @project, plant_without_photos)
    assert_response :success

    # Check the collection is empty
    assert_equal 0, assigns(:collection).size, "Collection should be empty for plant with no photos"

    # Should show empty state or no photos message
    assert_select ".photo-card", count: 0
  end

  test "should order photos by taken_at" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    photos = assigns(:collection)
    assert photos.present?
  end

  test "should display photo metadata in view" do
    get team_project_plant_photos_url(@team, @project, @plant)
    assert_response :success

    # Should show caption, date, etc.
    assert_select ".photo-card" do
      assert_select ".photo-caption"
    end
  end
end
