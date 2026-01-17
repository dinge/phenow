# frozen_string_literal: true

class PlantStageTransition < ApplicationRecord
  # Associations
  belongs_to :plant
  belongs_to :recorded_by, class_name: "User", optional: true, inverse_of: :plant_stage_transitions

  # Validations
  validates :to_stage, presence: true, inclusion: { in: Plant::STAGES }
  validates :from_stage, inclusion: { in: Plant::STAGES }, allow_blank: true
  validates :transitioned_at, presence: true

  # Scopes
  scope :chronological, -> { order(transitioned_at: :asc) }
  scope :reverse_chronological, -> { order(transitioned_at: :desc) }
  scope :for_plant, ->(plant) { where(plant: plant) }

  def duration
    # Calculate duration until the next transition or current time
    next_transition = plant.plant_stage_transitions
      .where("transitioned_at > ?", transitioned_at)
      .order(transitioned_at: :asc)
      .first

    end_time = next_transition&.transitioned_at || Time.current
    end_time - transitioned_at
  end
end
