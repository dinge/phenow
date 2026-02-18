# frozen_string_literal: true

require "test_helper"

class BadgeHelperTest < ActionView::TestCase
  include BadgeHelper

  # status_badge tests
  test "status_badge returns badge for active status" do
    result = status_badge("active")
    assert_match(/badge-active/, result)
    assert_match(/Active/, result)
    assert_match(/<span/, result)
  end

  test "status_badge returns badge for keeper status" do
    result = status_badge("keeper")
    assert_match(/badge-keeper/, result)
    assert_match(/Keeper/, result)
  end

  test "status_badge returns badge for culled status" do
    result = status_badge("culled")
    assert_match(/badge-culled/, result)
    assert_match(/Culled/, result)
  end

  test "status_badge returns badge for harvested status" do
    result = status_badge("harvested")
    assert_match(/badge-harvested/, result)
    assert_match(/Harvested/, result)
  end

  test "status_badge returns badge for archived status" do
    result = status_badge("archived")
    assert_match(/badge-archived/, result)
    assert_match(/Archived/, result)
  end

  test "status_badge accepts symbol status" do
    result = status_badge(:active)
    assert_match(/badge-active/, result)
    assert_match(/Active/, result)
  end

  test "status_badge returns nil for nil status" do
    assert_nil status_badge(nil)
  end

  test "status_badge returns nil for empty string" do
    assert_nil status_badge("")
  end

  test "status_badge titleizes status text" do
    result = status_badge("active")
    # Check that the text content is titleized
    assert_match(/>Active</, result)
    # Lowercase should not appear in the visible text
    refute_match(/>active</, result)
  end

  # stage_badge tests
  test "stage_badge returns badge for germination stage" do
    result = stage_badge("germination")
    assert_match(/badge-stage/, result)
    assert_match(/Germination/, result)
    assert_match(/<span/, result)
  end

  test "stage_badge returns badge for seedling stage" do
    result = stage_badge("seedling")
    assert_match(/badge-stage/, result)
    assert_match(/Seedling/, result)
  end

  test "stage_badge returns badge for vegetative stage" do
    result = stage_badge("vegetative")
    assert_match(/badge-stage/, result)
    assert_match(/Vegetative/, result)
  end

  test "stage_badge returns badge for flowering stage" do
    result = stage_badge("flowering")
    assert_match(/badge-stage/, result)
    assert_match(/Flowering/, result)
  end

  test "stage_badge handles pre_flower stage with underscore" do
    result = stage_badge("pre_flower")
    assert_match(/badge-stage/, result)
    assert_match(/Pre Flower/, result)
    refute_match(/_/, result)
  end

  test "stage_badge accepts symbol stage" do
    result = stage_badge(:flowering)
    assert_match(/badge-stage/, result)
    assert_match(/Flowering/, result)
  end

  test "stage_badge returns nil for nil stage" do
    assert_nil stage_badge(nil)
  end

  test "stage_badge returns nil for empty string" do
    assert_nil stage_badge("")
  end

  test "stage_badge replaces underscores with spaces" do
    result = stage_badge("pre_flower")
    assert_match(/Pre Flower/, result)
    refute_match(/_/, result)
  end

  test "stage_badge titleizes stage text" do
    result = stage_badge("flowering")
    assert_match(/Flowering/, result)
  end
end
