# frozen_string_literal: true

require "test_helper"

class TableHelperTest < ActionView::TestCase
  include TableHelper

  def setup
    @request = ActionDispatch::TestRequest.create
    @request.path = "/strains"
  end

  # Helper to stub url_for which is used by sort_link
  def url_for(options = {})
    # Handle both hash and string arguments
    return options.to_s if options.is_a?(String)

    query_params = options.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    "?#{query_params}"
  end

  test "sort_link generates link with ascending direction for new column" do
    params[:sort] = nil
    params[:dir] = nil

    result = sort_link(:name, "Name")

    assert_match(/sort=name/, result)
    assert_match(/dir=asc/, result)
    assert_match(/Name/, result)
    refute_match(/[↑↓]/, result)
  end

  test "sort_link generates link with descending direction when column is currently sorted ascending" do
    params[:sort] = "name"
    params[:dir] = "asc"

    result = sort_link(:name, "Name")

    assert_match(/sort=name/, result)
    assert_match(/dir=desc/, result)
    assert_match(/Name ↑/, result)
  end

  test "sort_link generates link with ascending direction when column is currently sorted descending" do
    params[:sort] = "name"
    params[:dir] = "desc"

    result = sort_link(:name, "Name")

    assert_match(/sort=name/, result)
    assert_match(/dir=asc/, result)
    assert_match(/Name ↓/, result)
  end

  test "sort_link preserves existing query parameters" do
    params[:sort] = "name"
    params[:dir] = "asc"
    params[:status] = "active"
    params[:page] = "2"

    # Populate request.query_parameters
    @request.GET.merge!(sort: "name", dir: "asc", status: "active", page: "2")

    result = sort_link(:breeder, "Breeder")

    assert_match(/status=active/, result)
    assert_match(/page=2/, result)
  end

  test "sort_link excludes old sort and dir params when preserving query parameters" do
    params[:sort] = "name"
    params[:dir] = "desc"
    params[:status] = "active"

    # Populate request.query_parameters
    @request.GET.merge!(sort: "name", dir: "desc", status: "active")

    result = sort_link(:breeder, "Breeder")

    # Should have new sort/dir
    assert_match(/sort=breeder/, result)
    assert_match(/dir=asc/, result)

    # Should preserve other params
    assert_match(/status=active/, result)
  end

  test "sort_link accepts symbols for column name" do
    params[:sort] = nil

    result = sort_link(:created_at, "Created")

    assert_match(/sort=created_at/, result)
    assert_match(/Created/, result)
  end

  test "sort_link accepts strings for column name" do
    params[:sort] = nil

    result = sort_link("updated_at", "Updated")

    assert_match(/sort=updated_at/, result)
    assert_match(/Updated/, result)
  end

  test "sort_link includes hover class" do
    result = sort_link(:name, "Name")
    assert_match(/class="hover:text-gray-700"/, result)
  end

  test "sort_link shows up arrow for ascending sort" do
    params[:sort] = "name"
    params[:dir] = "asc"

    result = sort_link(:name, "Name")
    assert_match(/↑/, result)
  end

  test "sort_link shows down arrow for descending sort" do
    params[:sort] = "name"
    params[:dir] = "desc"

    result = sort_link(:name, "Name")
    assert_match(/↓/, result)
  end

  test "sort_link shows no arrow for inactive column" do
    params[:sort] = "name"
    params[:dir] = "asc"

    result = sort_link(:breeder, "Breeder")
    refute_match(/[↑↓]/, result)
  end
end
