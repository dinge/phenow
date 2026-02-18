# frozen_string_literal: true

require "test_helper"

module Settings
  class TraitCategoriesControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :organizations, :trait_categories

    setup do
      @user = users(:marcus)
      @organization = organizations(:exotic_genetics)
      sign_in @user

      # Assume we need current_organization set (would be set by auth in real app)
      # For now we'll stub this in the controller
      @trait_category = trait_categories(:vigor_health)
    end

    test "should get index" do
      get settings_trait_categories_url
      assert_response :success
    end

    test "should get new" do
      get new_settings_trait_category_url
      assert_response :success
    end

    test "should create trait_category" do
      assert_difference("TraitCategory.count") do
        post settings_trait_categories_url, params: {
          trait_category: {
            name: "Custom Category",
            description: "A custom trait category",
            icon: "custom",
            display_order: 10
          }
        }
      end

      assert_redirected_to settings_trait_categories_url
    end

    test "should not create trait_category with invalid params" do
      assert_no_difference("TraitCategory.count") do
        post settings_trait_categories_url, params: {
          trait_category: {
            name: ""
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should get edit" do
      # Create org-specific category
      category = TraitCategory.create!(
        organization: @organization,
        name: "Test Category",
        slug: "test-category"
      )

      get edit_settings_trait_category_url(category)
      assert_response :success
    end

    test "should update trait_category" do
      category = TraitCategory.create!(
        organization: @organization,
        name: "Test Category",
        slug: "test-category"
      )

      patch settings_trait_category_url(category), params: {
        trait_category: {
          name: "Updated Category"
        }
      }

      assert_redirected_to settings_trait_categories_url
      category.reload
      assert_equal "Updated Category", category.name
    end

    test "should not update trait_category with invalid params" do
      category = TraitCategory.create!(
        organization: @organization,
        name: "Test Category",
        slug: "test-category"
      )

      patch settings_trait_category_url(category), params: {
        trait_category: {
          name: ""
        }
      }

      assert_response :unprocessable_entity
    end

    test "should destroy trait_category" do
      category = TraitCategory.create!(
        organization: @organization,
        name: "Test Category",
        slug: "test-category"
      )

      assert_difference("TraitCategory.count", -1) do
        delete settings_trait_category_url(category)
      end

      assert_redirected_to settings_trait_categories_url
    end

    test "should not destroy system default trait_category" do
      # System defaults have organization: nil
      assert_no_difference("TraitCategory.count") do
        delete settings_trait_category_url(@trait_category)
      end

      assert_redirected_to settings_trait_categories_url
    end
  end
end
