# frozen_string_literal: true

require "test_helper"

module Settings
  class TraitDefinitionsControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :organizations, :trait_categories, :trait_definitions

    setup do
      @user = users(:marcus)
      @organization = organizations(:exotic_genetics)
      sign_in @user

      @trait_category = trait_categories(:vigor_health)
      @trait_definition = trait_definitions(:overall_vigor)
    end

    test "should get index filtered by category" do
      get settings_trait_category_trait_definitions_url(@trait_category)
      assert_response :success
    end

    test "should get new" do
      get new_settings_trait_category_trait_definition_url(@trait_category)
      assert_response :success
    end

    test "should create trait_definition" do
      assert_difference("TraitDefinition.count") do
        post settings_trait_category_trait_definitions_url(@trait_category), params: {
          trait_definition: {
            name: "Custom Trait",
            description: "A custom trait",
            data_type: "numeric",
            unit: "cm",
            min_value: 0,
            max_value: 100
          }
        }
      end

      assert_redirected_to settings_trait_categories_url
    end

    test "should not create trait_definition with invalid params" do
      assert_no_difference("TraitDefinition.count") do
        post settings_trait_category_trait_definitions_url(@trait_category), params: {
          trait_definition: {
            name: "",
            data_type: "invalid"
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should get edit" do
      # Create org-specific definition
      definition = TraitDefinition.create!(
        organization: @organization,
        trait_category: @trait_category,
        name: "Test Trait",
        slug: "test-trait-#{SecureRandom.hex(4)}",
        data_type: "numeric"
      )

      get edit_settings_trait_definition_url(definition)
      assert_response :success
    end

    test "should update trait_definition" do
      definition = TraitDefinition.create!(
        organization: @organization,
        trait_category: @trait_category,
        name: "Test Trait",
        slug: "test-trait-#{SecureRandom.hex(4)}",
        data_type: "numeric"
      )

      patch settings_trait_definition_url(definition), params: {
        trait_definition: {
          name: "Updated Trait"
        }
      }

      assert_redirected_to settings_trait_categories_url
      definition.reload
      assert_equal "Updated Trait", definition.name
    end

    test "should not update trait_definition with invalid params" do
      definition = TraitDefinition.create!(
        organization: @organization,
        trait_category: @trait_category,
        name: "Test Trait",
        slug: "test-trait-#{SecureRandom.hex(4)}",
        data_type: "numeric"
      )

      patch settings_trait_definition_url(definition), params: {
        trait_definition: {
          name: "",
          data_type: "invalid"
        }
      }

      assert_response :unprocessable_entity
    end

    test "should destroy trait_definition" do
      definition = TraitDefinition.create!(
        organization: @organization,
        trait_category: @trait_category,
        name: "Test Trait",
        slug: "test-trait-#{SecureRandom.hex(4)}",
        data_type: "numeric"
      )

      assert_difference("TraitDefinition.count", -1) do
        delete settings_trait_definition_url(definition)
      end

      assert_redirected_to settings_trait_categories_url
    end

    test "should not destroy system default trait_definition" do
      # System defaults have organization: nil
      assert_no_difference("TraitDefinition.count") do
        delete settings_trait_definition_url(@trait_definition)
      end

      assert_redirected_to settings_trait_categories_url
    end
  end
end
