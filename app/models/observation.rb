# frozen_string_literal: true

class Observation < ApplicationRecord
  # Associations
  belongs_to :plant
  belongs_to :observed_by, class_name: "User", inverse_of: :observations

  has_many :trait_values, dependent: :destroy
  accepts_nested_attributes_for :trait_values, allow_destroy: true

  # Polymorphic
  has_many :photos, as: :photographable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  # Delegations
  delegate :project, :team, :organization, to: :plant

  # Validations
  validates :observed_at, presence: true
  validates :overall_score, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true

  # Scopes
  scope :chronological, -> { order(observed_at: :asc) }
  scope :reverse_chronological, -> { order(observed_at: :desc) }
  scope :by_user, ->(user) { where(observed_by: user) }
  scope :in_stage, ->(stage) { where(stage: stage) }

  # Callbacks
  before_validation :set_defaults

  def display_date
    observed_at.strftime("%b %d, %Y")
  end

  private

  def set_defaults
    self.observed_at ||= Time.current
    self.stage ||= plant&.current_stage
  end
end
