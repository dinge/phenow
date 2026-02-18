# frozen_string_literal: true

require "test_helper"

module Settings
  class TagsControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :organizations, :tags

    setup do
      @user = users(:marcus)
      @organization = organizations(:exotic_genetics)
      sign_in @user

      @tag = tags(:keeper_tag)
    end

    test "should get index" do
      get settings_tags_url
      assert_response :success
    end

    test "should get new" do
      get new_settings_tag_url
      assert_response :success
    end

    test "should create tag" do
      assert_difference("Tag.count") do
        post settings_tags_url, params: {
          tag: {
            name: "New Tag",
            color: "#FF5733"
          }
        }
      end

      assert_redirected_to settings_tags_url
    end

    test "should not create tag with invalid params" do
      assert_no_difference("Tag.count") do
        post settings_tags_url, params: {
          tag: {
            name: ""
          }
        }
      end

      assert_response :unprocessable_entity
    end

    test "should get edit" do
      get edit_settings_tag_url(@tag)
      assert_response :success
    end

    test "should update tag" do
      patch settings_tag_url(@tag), params: {
        tag: {
          name: "Updated Tag"
        }
      }

      assert_redirected_to settings_tags_url
      @tag.reload
      assert_equal "Updated Tag", @tag.name
    end

    test "should not update tag with invalid params" do
      patch settings_tag_url(@tag), params: {
        tag: {
          name: ""
        }
      }

      assert_response :unprocessable_entity
    end

    test "should destroy tag" do
      assert_difference("Tag.count", -1) do
        delete settings_tag_url(@tag)
      end

      assert_redirected_to settings_tags_url
    end
  end
end
