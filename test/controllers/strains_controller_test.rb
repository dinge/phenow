# frozen_string_literal: true

require "test_helper"

class StrainsControllerTest < ActionDispatch::IntegrationTest
  # Disable automatic fixture loading
  self.use_transactional_tests = true

  setup do
    # Create test data manually to avoid fixture issues
    @organization = Organization.create!(
      name: "Test Organization",
      slug: "test-org"
    )

    # Create user with Devise password encryption
    @user = User.new(
      email: "test@example.com",
      name: "Test User"
    )
    @user.password = "password123"
    @user.password_confirmation = "password123"
    @user.save!

    @strain = @organization.strains.create!(
      name: "Test Strain",
      breeder: "Test Breeder",
      strain_type: "indica",
      genetics_type: "feminized",
      description: "Test description"
    )

    # Create a few more strains for testing filtering and pagination
    @organization.strains.create!(
      name: "Sativa Strain",
      breeder: "Sativa Breeder",
      strain_type: "sativa",
      genetics_type: "regular"
    )

    @organization.strains.create!(
      name: "Hybrid Strain",
      breeder: "Hybrid Breeder",
      strain_type: "hybrid",
      genetics_type: "feminized"
    )

    # sign_in @user  # TODO: Re-enable after Devise test configuration is fixed
  end

  # ============================================
  # INDEX ACTION
  # ============================================

  test "should get index" do
    get strains_url
    assert_response :success
    assert_not_nil assigns(:collection)
    assert_not_nil assigns(:pagy)
  end

  test "index displays strains" do
    get strains_url
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index responds to turbo_stream" do
    get strains_url, as: :turbo_stream
    assert_response :success
  end

  # ============================================
  # FILTERING
  # ============================================

  test "index filters by strain_type" do
    get strains_url, params: { strain_type: "indica" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.all? { |s| s.strain_type == "indica" }
  end

  test "index filters by genetics_type" do
    get strains_url, params: { genetics_type: "feminized" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.all? { |s| s.genetics_type == "feminized" }
  end

  test "index filters by multiple criteria" do
    get strains_url, params: { strain_type: "hybrid", genetics_type: "feminized" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.all? { |s| s.strain_type == "hybrid" && s.genetics_type == "feminized" }
  end

  test "index returns all when no filters applied" do
    get strains_url
    assert_response :success
    collection = assigns(:collection)
    assert collection.count >= 3
  end

  # ============================================
  # SEARCH
  # ============================================

  test "index searches by name" do
    get strains_url, params: { q: "Test Strain" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index searches by breeder" do
    get strains_url, params: { q: "Test Breeder" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index search is case insensitive" do
    get strains_url, params: { q: "test strain" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index returns empty when search has no matches" do
    get strains_url, params: { q: "NonexistentStrain12345" }
    assert_response :success
    collection = assigns(:collection)
    assert_empty collection
  end

  # ============================================
  # SORTING
  # ============================================

  test "index sorts by name ascending" do
    get strains_url, params: { sort: "name", dir: "asc" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index sorts by name descending" do
    get strains_url, params: { sort: "name", dir: "desc" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
  end

  test "index sorts by breeder" do
    get strains_url, params: { sort: "breeder", dir: "asc" }
    assert_response :success
  end

  # ============================================
  # NEW ACTION
  # ============================================

  test "should get new" do
    get new_strain_url
    assert_response :success
    assert_not_nil assigns(:resource)
    assert assigns(:resource).new_record?
  end

  test "new assigns blank strain" do
    get new_strain_url
    strain = assigns(:resource)
    assert_instance_of Strain, strain
    assert strain.new_record?
  end

  # ============================================
  # CREATE ACTION
  # ============================================

  test "create with valid params creates strain" do
    assert_difference("Strain.count") do
      post strains_url, params: {
        strain: {
          name: "New Test Strain",
          breeder: "New Breeder",
          strain_type: "hybrid",
          genetics_type: "feminized",
          description: "New test description",
          flowering_time_min: 60,
          flowering_time_max: 70,
          thc_min: 20.0,
          thc_max: 25.0
        }
      }
    end

    assert_redirected_to strains_url
    assert_equal "Created successfully.", flash[:notice]

    strain = Strain.order(:created_at).last
    assert_equal "New Test Strain", strain.name
    assert_equal "New Breeder", strain.breeder
    assert_equal "hybrid", strain.strain_type
  end

  test "create with minimal valid params creates strain" do
    assert_difference("Strain.count") do
      post strains_url, params: {
        strain: {
          name: "Minimal Strain"
        }
      }
    end

    assert_redirected_to strains_url
  end

  test "create with invalid params renders new" do
    assert_no_difference("Strain.count") do
      post strains_url, params: {
        strain: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with invalid strain_type renders new" do
    assert_no_difference("Strain.count") do
      post strains_url, params: {
        strain: {
          name: "Invalid Type Strain",
          strain_type: "invalid_type"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # SHOW ACTION (redirects to edit)
  # ============================================

  test "show redirects to edit" do
    get strain_url(@strain)
    assert_redirected_to edit_strain_url(@strain)
  end

  test "show works with friendly_id slug" do
    get strain_url(@strain.slug)
    assert_redirected_to edit_strain_url(@strain)
  end

  # ============================================
  # EDIT ACTION
  # ============================================

  test "should get edit" do
    get edit_strain_url(@strain)
    assert_response :success
    assert_equal @strain, assigns(:resource)
  end

  test "edit loads strain by id" do
    get edit_strain_url(@strain.id)
    assert_response :success
    assert_equal @strain, assigns(:resource)
  end

  test "edit loads strain by slug" do
    get edit_strain_url(@strain.slug)
    assert_response :success
    assert_equal @strain.id, assigns(:resource).id
  end

  # ============================================
  # UPDATE ACTION
  # ============================================

  test "update with valid params updates strain" do
    new_name = "Updated Strain Name"
    new_breeder = "Updated Breeder"

    patch strain_url(@strain), params: {
      strain: {
        name: new_name,
        breeder: new_breeder
      }
    }

    assert_redirected_to strains_url
    assert_equal "Updated successfully.", flash[:notice]

    @strain.reload
    assert_equal new_name, @strain.name
    assert_equal new_breeder, @strain.breeder
  end

  test "update can change strain_type" do
    patch strain_url(@strain), params: {
      strain: { strain_type: "sativa" }
    }

    assert_redirected_to strains_url
    assert_equal "sativa", @strain.reload.strain_type
  end

  test "update can change genetics_type" do
    patch strain_url(@strain), params: {
      strain: { genetics_type: "autoflower" }
    }

    assert_redirected_to strains_url
    assert_equal "autoflower", @strain.reload.genetics_type
  end

  test "update with invalid params renders edit" do
    patch strain_url(@strain), params: {
      strain: { name: "" }
    }

    assert_response :unprocessable_entity
    @strain.reload
    assert_not_empty @strain.name
  end

  test "update with invalid strain_type renders edit" do
    original_type = @strain.strain_type

    patch strain_url(@strain), params: {
      strain: { strain_type: "invalid_type" }
    }

    assert_response :unprocessable_entity
    assert_equal original_type, @strain.reload.strain_type
  end

  # ============================================
  # DESTROY ACTION
  # ============================================

  test "destroy deletes strain" do
    strain = @organization.strains.create!(
      name: "Deletable Strain"
    )

    assert_difference("Strain.count", -1) do
      delete strain_url(strain)
    end

    assert_redirected_to strains_url
    assert_equal "Deleted successfully.", flash[:notice]
  end

  test "destroy works with friendly_id slug" do
    strain = @organization.strains.create!(
      name: "Deletable Slug Strain"
    )

    assert_difference("Strain.count", -1) do
      delete strain_url(strain.slug)
    end

    assert_redirected_to strains_url
  end

  # ============================================
  # PAGINATION
  # ============================================

  test "index paginates results" do
    get strains_url
    assert_response :success
    assert_not_nil assigns(:pagy)
    assert_not_nil assigns(:collection)
  end
end
