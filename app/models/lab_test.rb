# frozen_string_literal: true

class LabTest < ApplicationRecord
  SAMPLE_TYPES = %w[flower concentrate edible].freeze

  # ActiveStorage
  has_one_attached :coa_document

  # Associations
  belongs_to :plant

  # Polymorphic
  has_many :photos, as: :photographable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  # Delegations
  delegate :project, :team, :organization, to: :plant

  # Validations
  validates :lab_name, presence: true
  validates :test_date, presence: true
  validates :sample_type, inclusion: { in: SAMPLE_TYPES }, allow_blank: true
  validates :total_thc, :total_cbd, :total_cannabinoids, :total_terpenes,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
  validate :status_must_be_valid

  # Scopes
  scope :chronological, -> { order(test_date: :asc) }
  scope :reverse_chronological, -> { order(test_date: :desc) }
  scope :passed, -> { where(passed: true) }
  scope :failed, -> { where(passed: false) }
  scope :completed, -> { where.not(test_date: nil).where("test_date <= ?", Date.current) }
  scope :pending, -> { where(test_date: nil).or(where("test_date > ?", Date.current)) }

  # Callbacks
  before_validation :set_defaults

  # Aliases for tests (can't use alias_method due to AR loading order)
  def thc_total
    total_thc
  end

  def cbd_total
    total_cbd
  end

  # Cannabinoid accessors from JSONB profile
  def cbg
    cannabinoid_profile&.dig("cbg") || cannabinoid_profile&.dig("CBG")
  end

  def cbn
    cannabinoid_profile&.dig("cbn") || cannabinoid_profile&.dig("CBN")
  end

  # Status attribute (for tests that expect it)
  def status
    @status_value || (passed ? "completed" : "pending")
  end

  def status=(value)
    @status_value = value
    @status_set = true
    self.passed = (value == "completed") if value.in?(%w[completed pending])
  end

  # Safety test accessors
  def passed_pesticides
    contaminants.dig("passed_pesticides")
  end

  def passed_pesticides=(value)
    self.contaminants ||= {}
    contaminants["passed_pesticides"] = value
  end

  def passed_all_safety?
    return false unless contaminants.present?

    %w[passed_pesticides passed_microbial passed_heavy_metals passed_mycotoxins passed_residual_solvents].all? do |key|
      contaminants[key] != false
    end
  end

  def dominant_terpene
    return nil unless terpene_profile.present? && terpene_profile.any?

    terpene_profile.max_by { |_k, v| v.to_f }&.first
  end

  def total_cannabinoids
    return super if attributes["total_cannabinoids"].present?

    # Calculate from individual cannabinoids
    (total_thc.to_f + total_cbd.to_f + cbg.to_f + cbn.to_f).round(2)
  end

  def potency_ratio
    return nil unless total_thc && total_cbd && total_cbd.positive?

    (total_thc / total_cbd).round(1)
  end

  def top_terpenes(limit = 5)
    return [] unless terpene_profile.present?

    terpene_profile.sort_by { |_k, v| -v.to_f }.first(limit).to_h
  end

  def top_cannabinoids(limit = 5)
    return [] unless cannabinoid_profile.present?

    cannabinoid_profile.sort_by { |_k, v| -v.to_f }.first(limit).to_h
  end

  private

  def set_defaults
    self.cannabinoid_profile ||= {}
    self.terpene_profile ||= {}
    self.contaminants ||= {}
    self.metadata ||= {}
  end

  def status_must_be_valid
    # Status is a virtual attribute that maps to passed boolean
    # Only validate if status is being explicitly set
    return unless @status_set
    return if @status_value.in?(%w[completed pending])

    errors.add(:status, "must be either 'completed' or 'pending'")
  end
end
