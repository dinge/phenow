# frozen_string_literal: true

class ProjectGoal < ApplicationRecord
  # Associations
  belongs_to :project
  belongs_to :target_trait, class_name: "TraitDefinition", optional: true

  # Validations
  validates :title, presence: true

  # Scopes
  scope :by_priority, -> { order(priority: :desc) }
  scope :achieved, -> { where(achieved: true) }
  scope :pending, -> { where(achieved: false) }

  # Callbacks
  before_validation :set_defaults

  def mark_achieved!
    update!(achieved: true)
  end

  private

  def set_defaults
    self.priority ||= 0
    self.achieved ||= false
  end
end
