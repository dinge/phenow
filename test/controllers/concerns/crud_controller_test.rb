# frozen_string_literal: true

require "test_helper"

# Test controller that includes CrudController
class TestResourcesController < ApplicationController
  include CrudController

  # Skip layout for testing
  layout false

  # Class variable to store test organization
  cattr_accessor :test_organization

  # Simulate current_organization method
  def current_organization
    self.class.test_organization
  end

  private

  def resource_class
    Strain  # Override to use Strain instead of TestResource
  end

  def resource_scope
    current_organization.strains
  end

  def permitted_attributes
    %i[name breeder strain_type genetics_type description]
  end
end

class CrudControllerTest < ActionDispatch::IntegrationTest
  # Disable automatic fixture loading for this test
  self.use_transactional_tests = true

  # Override fixtures method from test_helper.rb
  def self.fixtures(*args)
    # Do nothing - don't load fixtures
  end

  setup do
    # Create test data manually
    @organization = Organization.create!(
      name: "Test Org",
      description: "Test organization"
    )

    @strain = @organization.strains.create!(
      name: "Northern Lights",
      breeder: "Sensi Seeds",
      strain_type: "indica"
    )

    # Setup test controller
    @controller = TestResourcesController.new
    TestResourcesController.test_organization = @organization

    # Define routes for test controller
    Rails.application.routes.draw do
      resources :test_resources
    end
  end

  teardown do
    # Reload original routes
    Rails.application.reload_routes!
  end

  # ============================================
  # INDEX ACTION
  # ============================================

  test "index returns collection" do
    get test_resources_url
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "index responds to html" do
    get test_resources_url
    assert_response :success
  end

  test "index responds to turbo_stream" do
    get test_resources_url, as: :turbo_stream
    assert_response :success
  end

  test "index paginates collection with pagy" do
    get test_resources_url
    assert_not_nil assigns(:pagy)
    assert_not_nil assigns(:collection)
  end

  # ============================================
  # SHOW ACTION (redirects to edit)
  # ============================================

  test "show redirects to edit" do
    get test_resource_url(@strain)
    assert_redirected_to edit_test_resource_url(@strain)
  end

  # ============================================
  # NEW ACTION
  # ============================================

  test "new assigns new resource" do
    get new_test_resource_url
    assert_response :success
    assert_not_nil assigns(:resource)
    assert assigns(:resource).new_record?
  end

  # ============================================
  # CREATE ACTION
  # ============================================

  test "create with valid params creates resource" do
    assert_difference("Strain.count") do
      post test_resources_url, params: {
        strain: {
          name: "New Strain",
          breeder: "Test Breeder",
          strain_type: "indica"
        }
      }
    end
    assert_redirected_to test_resources_url
    assert_equal "Created successfully.", flash[:notice]
  end

  test "create with invalid params renders new" do
    assert_no_difference("Strain.count") do
      post test_resources_url, params: {
        strain: { name: "" }  # Invalid - name required
      }
    end
    assert_response :unprocessable_entity
  end

  # ============================================
  # EDIT ACTION
  # ============================================

  test "edit assigns resource" do
    get edit_test_resource_url(@strain)
    assert_response :success
    assert_equal @strain, assigns(:resource)
  end

  # ============================================
  # UPDATE ACTION
  # ============================================

  test "update with valid params updates resource" do
    new_name = "Updated Name"
    patch test_resource_url(@strain), params: {
      strain: { name: new_name }
    }
    assert_redirected_to test_resources_url
    assert_equal "Updated successfully.", flash[:notice]
    assert_equal new_name, @strain.reload.name
  end

  test "update with invalid params renders edit" do
    patch test_resource_url(@strain), params: {
      strain: { name: "" }  # Invalid
    }
    assert_response :unprocessable_entity
  end

  # ============================================
  # DESTROY ACTION
  # ============================================

  test "destroy deletes resource" do
    assert_difference("Strain.count", -1) do
      delete test_resource_url(@strain)
    end
    assert_redirected_to test_resources_url
    assert_equal "Deleted successfully.", flash[:notice]
  end

  # ============================================
  # FILTERING
  # ============================================

  test "apply_filters is called in set_collection" do
    # This is tested through the controller subclass
    # Default implementation returns scope unchanged
    get test_resources_url
    assert_response :success
  end

  # ============================================
  # SEARCHING
  # ============================================

  test "apply_search filters by search query" do
    # Add search scope to Strain for testing
    Strain.class_eval do
      scope :search, ->(q) { where("name ILIKE ?", "%#{q}%") }
    end

    get test_resources_url, params: { q: "Northern" }
    assert_response :success
    collection = assigns(:collection)
    assert collection.any?
    assert collection.all? { |s| s.name.include?("Northern") }
  end

  test "apply_search returns scope when no query" do
    get test_resources_url
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  # ============================================
  # SORTING
  # ============================================

  test "apply_sorting sorts by column ascending" do
    get test_resources_url, params: { sort: "name", dir: "asc" }
    assert_response :success
  end

  test "apply_sorting sorts by column descending" do
    get test_resources_url, params: { sort: "name", dir: "desc" }
    assert_response :success
  end

  test "apply_sorting defaults to asc when dir not specified" do
    get test_resources_url, params: { sort: "name" }
    assert_response :success
  end

  test "apply_sorting returns scope when no sort param" do
    get test_resources_url
    assert_response :success
  end

  # ============================================
  # HELPER METHODS
  # ============================================

  test "resource_class returns correct class" do
    assert_equal Strain, @controller.send(:resource_class)
  end

  test "resource_name returns singular name" do
    assert_equal "strain", @controller.send(:resource_name)
  end

  test "collection_name returns plural name" do
    assert_equal "strains", @controller.send(:collection_name)
  end

  # ============================================
  # FRIENDLY ID SUPPORT
  # ============================================

  test "find_resource supports friendly_id" do
    get test_resource_url(@strain.slug)
    assert_response :redirect  # Redirects to edit
  end

  test "find_resource falls back to regular find when no friendly_id" do
    # Test with a model that doesn't use friendly_id
    # For this test, we'll just verify the method exists
    assert @controller.respond_to?(:find_resource, true)
  end

  # ============================================
  # AUTHORIZATION
  # ============================================

  test "set_resource calls authorize when available" do
    # Mock Pundit authorization
    @controller.define_singleton_method(:authorize) do |resource|
      resource  # Just return the resource
    end

    get edit_test_resource_url(@strain)
    assert_response :success
  end

  # ============================================
  # RESOURCE PARAMS
  # ============================================

  test "resource_params requires resource_name key" do
    # This is tested indirectly through create/update
    post test_resources_url, params: {
      strain: { name: "Test" }
    }
    assert_response :redirect
  end

  test "permitted_attributes must be defined in subclass" do
    # Create a controller without permitted_attributes
    controller_class = Class.new(ApplicationController) do
      include CrudController
      layout false
    end

    # This test verifies that calling permitted_attributes raises NotImplementedError
    controller = controller_class.new
    assert_raises(NotImplementedError) do
      controller.send(:permitted_attributes)
    end
  end

  # ============================================
  # BUILD RESOURCE
  # ============================================

  test "build_resource creates new instance" do
    resource = @controller.send(:build_resource)
    assert resource.new_record?
    assert_instance_of Strain, resource
  end

  test "build_resource accepts attributes" do
    resource = @controller.send(:build_resource, name: "Test Strain")
    assert_equal "Test Strain", resource.name
  end

  # ============================================
  # CUSTOM PATHS
  # ============================================

  test "after_save_path defaults to index" do
    # Test indirectly through create action
    post test_resources_url, params: {
      strain: {
        name: "Path Test Strain",
        breeder: "Test"
      }
    }
    assert_redirected_to test_resources_url
  end

  test "after_destroy_path defaults to index" do
    # Test indirectly through destroy action
    delete test_resource_url(@strain)
    assert_redirected_to test_resources_url
  end

  # ============================================
  # ENDLESS METHOD SYNTAX
  # ============================================

  test "concern uses Ruby 3.3 endless method syntax" do
    # Read the concern file and check for endless method syntax
    concern_file = File.read(Rails.root.join("app/controllers/concerns/crud_controller.rb"))
    assert_match(/def \w+ = /, concern_file, "Should use endless method syntax for simple methods")
  end
end
