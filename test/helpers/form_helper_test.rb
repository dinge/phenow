# frozen_string_literal: true

require "test_helper"

class FormHelperTest < ActionView::TestCase
  include FormHelper

  class MockRecord
    attr_accessor :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end
  end

  test "form_input_class returns form-input when no errors" do
    record = MockRecord.new
    assert_equal "form-input", form_input_class(record, :name)
  end

  test "form_input_class returns form-input form-input-error when field has errors" do
    record = MockRecord.new
    record.errors.add(:name, "can't be blank")
    assert_equal "form-input form-input-error", form_input_class(record, :name)
  end

  test "form_input_class returns form-input for field without errors when other fields have errors" do
    record = MockRecord.new
    record.errors.add(:email, "is invalid")
    assert_equal "form-input", form_input_class(record, :name)
  end

  test "form_input_class handles nil record safely" do
    assert_equal "form-input", form_input_class(nil, :name)
  end

  test "error_for returns nil when no errors" do
    record = MockRecord.new
    assert_nil error_for(record, :name)
  end

  test "error_for returns error message paragraph when field has errors" do
    record = MockRecord.new
    record.errors.add(:name, "can't be blank")
    result = error_for(record, :name)

    assert_includes result, "can&#39;t be blank"
    assert_match(/class="form-error"/, result)
    assert_match(/<p/, result)
  end

  test "error_for returns first error when multiple errors exist" do
    record = MockRecord.new
    record.errors.add(:name, "can't be blank")
    record.errors.add(:name, "is too short")
    result = error_for(record, :name)

    assert_includes result, "can&#39;t be blank"
    refute_includes result, "is too short"
  end

  test "error_for handles nil record safely" do
    assert_nil error_for(nil, :name)
  end

  test "error_for returns nil for field without errors when other fields have errors" do
    record = MockRecord.new
    record.errors.add(:email, "is invalid")
    assert_nil error_for(record, :name)
  end
end
