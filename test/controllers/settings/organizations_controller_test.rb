# frozen_string_literal: true

require "test_helper"

module Settings
  class OrganizationsControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :organizations

    setup do
      @user = users(:marcus)
      @organization = organizations(:exotic_genetics)
      sign_in @user
    end

    test "should get edit" do
      get edit_settings_organization_url
      assert_response :success
      assert_not_nil assigns(:resource)
      assert_equal @organization, assigns(:resource)
    end

    test "should update organization with valid params" do
      patch settings_organization_url, params: {
        organization: {
          name: "Updated Organization Name"
        }
      }

      assert_redirected_to edit_settings_organization_url
      @organization.reload
      assert_equal "Updated Organization Name", @organization.name
    end

    test "should not update organization with invalid params" do
      patch settings_organization_url, params: {
        organization: {
          name: ""
        }
      }

      assert_response :unprocessable_entity
      @organization.reload
      assert_not_equal "", @organization.name
    end

    test "should update organization settings" do
      new_settings = {
        timezone: "America/New_York",
        default_flowering_schedule: "11/13"
      }

      patch settings_organization_url, params: {
        organization: {
          settings: new_settings
        }
      }

      assert_redirected_to edit_settings_organization_url
      @organization.reload
      assert_equal "America/New_York", @organization.settings["timezone"]
      assert_equal "11/13", @organization.settings["default_flowering_schedule"]
    end
  end
end
