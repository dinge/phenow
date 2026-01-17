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
  validates :sample_type, inclusion: { in: SAMPLE_TYPES }, allow_blank: true
  validates :total_thc, :total_cbd, :total_cannabinoids, :total_terpenes,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true

  # Scopes
  scope :chronological, -> { order(test_date: :asc) }
  scope :reverse_chronological, -> { order(test_date: :desc) }
  scope :passed, -> { where(passed: true) }
  scope :failed, -> { where(passed: false) }

  # Callbacks
  before_validation :set_defaults

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
end
