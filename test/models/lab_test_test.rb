# frozen_string_literal: true

require "test_helper"

class LabTestTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid lab test" do
    assert_valid lab_tests(:plant_1_coa)
  end

  test "requires plant" do
    lab_test = LabTest.new(lab_name: "Test Lab", test_date: Date.current)
    assert_invalid lab_test, :plant
  end

  test "requires lab_name" do
    lab_test = lab_tests(:plant_1_coa)
    lab_test.lab_name = nil
    assert_invalid lab_test, :lab_name
  end

  test "requires test_date" do
    lab_test = lab_tests(:plant_1_coa)
    lab_test.test_date = nil
    assert_invalid lab_test, :test_date
  end

  test "validates status inclusion" do
    lab_test = lab_tests(:plant_1_coa)
    lab_test.status = "invalid"
    assert_invalid lab_test, :status
  end

  # === Associations ===

  test "belongs to plant" do
    assert_equal plants(:plant_1), lab_tests(:plant_1_coa).plant
  end

  # === Cannabinoid Data ===

  test "thc_total stored correctly" do
    assert_in_delta 26.8, lab_tests(:plant_1_coa).thc_total, 0.01
  end

  test "cbd_total stored correctly" do
    assert_in_delta 0.3, lab_tests(:plant_1_coa).cbd_total, 0.01
  end

  test "terpene_profile stored correctly" do
    profile = lab_tests(:plant_1_coa).terpene_profile
    assert_in_delta 1.2, profile["caryophyllene"], 0.01
    assert_in_delta 0.9, profile["limonene"], 0.01
  end

  # === Safety Tests ===

  test "passed_all_safety? returns true when all safety tests pass" do
    assert lab_tests(:plant_1_coa).passed_all_safety?
  end

  test "passed_all_safety? returns false when any safety test fails" do
    lab_test = lab_tests(:plant_1_coa)
    lab_test.passed_pesticides = false
    assert_not lab_test.passed_all_safety?
  end

  # === Scopes ===

  test "completed returns completed lab tests" do
    completed = LabTest.completed
    assert completed.all? { |lt| lt.status == "completed" }
    assert_includes completed, lab_tests(:plant_1_coa)
  end

  test "pending returns pending lab tests" do
    pending = LabTest.pending
    assert pending.all? { |lt| lt.status == "pending" }
  end

  # === Instance Methods ===

  test "dominant_terpene returns highest concentration terpene" do
    assert_equal "caryophyllene", lab_tests(:plant_1_coa).dominant_terpene
  end

  test "total_cannabinoids calculates sum" do
    lt = lab_tests(:plant_1_coa)
    expected = lt.thc_total + lt.cbd_total + lt.cbg.to_f + lt.cbn.to_f
    assert_in_delta expected, lt.total_cannabinoids, 0.1
  end
end
