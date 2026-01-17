# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Helper to assert difference in count
    def assert_difference_in(expression, difference = 1, &block)
      assert_difference(expression, difference, &block)
    end

    # Helper to assert valid record
    def assert_valid(record, message = nil)
      assert record.valid?, message || "Expected #{record.class.name} to be valid: #{record.errors.full_messages.join(', ')}"
    end

    # Helper to assert invalid record
    def assert_invalid(record, attribute = nil, message = nil)
      assert_not record.valid?, message || "Expected #{record.class.name} to be invalid"
      assert record.errors[attribute].any?, "Expected errors on #{attribute}" if attribute
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # Include Devise test helpers
    include Devise::Test::IntegrationHelpers
  end
end
