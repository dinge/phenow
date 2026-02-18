# frozen_string_literal: true

class TraitCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :organization, optional: true  # nil = system default

  has_many :trait_definitions, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(display_order: :asc, name: :asc) }
  scope :system_defaults, -> { where(organization_id: nil) }
  scope :for_organization, ->(org) { where(organization_id: [nil, org.id]) }

  # Callbacks
  before_validation :set_defaults

  def system_default?
    organization_id.nil?
  end

  def trait_count
    trait_definitions.count
  end

  private

  def set_defaults
    self.display_order ||= 0
  end
end
