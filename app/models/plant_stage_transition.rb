# frozen_string_literal: true

class PlantStageTransition < ApplicationRecord
  # Associations
  belongs_to :plant
  belongs_to :recorded_by, class_name: "User", optional: true, inverse_of: :plant_stage_transitions

  # Validations
  validates :to_stage, presence: true
  validates :transitioned_at, presence: true

  # Scopes
  scope :chronological, -> { order(transitioned_at: :asc) }
  scope :reverse_chronological, -> { order(transitioned_at: :desc) }

  # Callbacks
  before_validation :set_defaults

  private

  def set_defaults
    self.transitioned_at ||= Time.current
  end
end
