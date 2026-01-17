# frozen_string_literal: true

class TraitDefinition < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  DATA_TYPES = %w[numeric scale select boolean text].freeze

  # Associations
  belongs_to :organization, optional: true  # nil = system default
  belongs_to :trait_category

  has_many :trait_values, dependent: :destroy
  has_many :project_goals, foreign_key: :target_trait_id, dependent: :nullify, inverse_of: :target_trait

  # Validations
  validates :name, presence: true
  validates :slug, presence: true
  validates :data_type, presence: true, inclusion: { in: DATA_TYPES }

  # Scopes
  scope :ordered, -> { order(display_order: :asc, name: :asc) }
  scope :system_defaults, -> { where(system_default: true) }
  scope :for_organization, ->(org) { where(organization_id: [nil, org.id]) }
  scope :for_stage, ->(stage) { where("? = ANY(applicable_stages) OR applicable_stages = '{}'", stage) }

  # Callbacks
  before_validation :set_defaults

  def system_default?
    system_default == true || organization_id.nil?
  end

  def numeric?
    data_type == "numeric"
  end

  def scale?
    data_type == "scale"
  end

  def select?
    data_type == "select"
  end

  def boolean?
    data_type == "boolean"
  end

  def text?
    data_type == "text"
  end

  private

  def set_defaults
    self.display_order ||= 0
    self.system_default ||= false
    self.scale_labels ||= {}
    self.options ||= []
    self.applicable_stages ||= []
  end
end
