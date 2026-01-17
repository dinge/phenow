# frozen_string_literal: true

class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :team

  PROJECT_TYPES = %w[phenohunt breeding preservation].freeze
  STATUSES = %w[planning active completed archived].freeze

  # Associations
  belongs_to :team
  belongs_to :strain, optional: true

  has_many :project_goals, dependent: :destroy
  has_many :plants, dependent: :destroy

  # Polymorphic
  has_many :photos, as: :photographable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  # Delegations
  delegate :organization, to: :team

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :team_id }
  validates :project_type, presence: true, inclusion: { in: PROJECT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Scopes
  scope :search, ->(query) { where("name ILIKE :q OR description ILIKE :q", q: "%#{query}%") }
  scope :active, -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }
  scope :phenohunts, -> { where(project_type: "phenohunt") }

  # Callbacks
  before_validation :set_defaults

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def keeper_count
    plants.where(status: "keeper").count
  end

  def culled_count
    plants.where(status: "culled").count
  end

  def completion_percentage
    return 0 if plants.count.zero?

    decided = plants.where(status: %w[keeper culled]).count
    (decided.to_f / plants.count * 100).round(1)
  end

  private

  def set_defaults
    self.project_type ||= "phenohunt"
    self.status ||= "active"
    self.settings ||= {}
  end

  # Override FriendlyId to only generate slug when blank, not to resolve conflicts
  def should_generate_new_friendly_id?
    slug.blank?
  end
end
