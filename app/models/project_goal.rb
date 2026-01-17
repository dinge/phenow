# frozen_string_literal: true

class ProjectGoal < ApplicationRecord
  # Associations
  belongs_to :project
  belongs_to :target_trait, class_name: "TraitDefinition", optional: true

  # Delegations
  delegate :team, :organization, to: :project

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :priority, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_priority, -> { order(priority: :asc) }
  scope :achieved, -> { where(achieved: true) }
  scope :pending, -> { where(achieved: false) }

  # Callbacks
  before_validation :set_defaults

  def mark_achieved!
    update!(achieved: true)
  end

  private

  def set_defaults
    self.achieved ||= false
  end
end
