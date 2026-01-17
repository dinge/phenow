# frozen_string_literal: true

class Strain < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :organization

  STRAIN_TYPES = %w[indica sativa hybrid ruderalis].freeze
  GENETICS_TYPES = %w[regular feminized autoflower].freeze

  # Associations
  belongs_to :organization

  has_many :parent_lineages, class_name: "StrainLineage",
           foreign_key: :child_strain_id, dependent: :destroy, inverse_of: :child_strain
  has_many :parent_strains, through: :parent_lineages

  has_many :child_lineages, class_name: "StrainLineage",
           foreign_key: :parent_strain_id, dependent: :destroy, inverse_of: :parent_strain
  has_many :child_strains, through: :child_lineages

  has_many :projects, dependent: :nullify
  has_many :plants, dependent: :nullify

  # Polymorphic
  has_many :photos, as: :photographable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id }
  validates :strain_type, inclusion: { in: STRAIN_TYPES }, allow_blank: true
  validates :genetics_type, inclusion: { in: GENETICS_TYPES }, allow_blank: true

  # Scopes
  scope :public_strains, -> { where(public: true) }
  scope :verified, -> { where(verified: true) }
  scope :by_type, ->(type) { where(strain_type: type) }

  # Callbacks
  before_validation :set_defaults

  def mother
    parent_lineages.find_by(parent_role: "mother")&.parent_strain
  end

  def father
    parent_lineages.find_by(parent_role: "father")&.parent_strain
  end

  def full_lineage
    return lineage_text if lineage_text.present?

    parents = parent_strains.pluck(:name)
    parents.join(" x ") if parents.any?
  end

  private

  def set_defaults
    self.public ||= false
    self.verified ||= false
    self.metadata ||= {}
    self.dominant_terpenes ||= []
    self.effects ||= []
    self.aromas ||= []
  end
end
