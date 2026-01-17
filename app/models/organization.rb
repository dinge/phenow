# frozen_string_literal: true

class Organization < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :teams, dependent: :destroy
  has_many :memberships, through: :teams
  has_many :users, through: :memberships

  has_many :strains, dependent: :destroy
  has_many :trait_categories, dependent: :destroy
  has_many :trait_definitions, dependent: :destroy
  has_many :tags, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Class methods
  def self.default
    find_or_create_by!(slug: "system") do |org|
      org.name = "Phenow System"
      org.settings = { system: true }
    end
  end

  # Callbacks
  before_validation :set_defaults

  private

  def set_defaults
    self.settings ||= {}
  end
end
