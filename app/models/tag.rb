# frozen_string_literal: true

class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :organization

  # Associations
  belongs_to :organization

  has_many :taggings, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id }

  # Scopes
  scope :alphabetical, -> { order(name: :asc) }

  def tagged_count
    taggings.count
  end

  alias_method :usage_count, :tagged_count

  # Override FriendlyId to only generate slug when blank
  def should_generate_new_friendly_id?
    slug.blank?
  end
end
