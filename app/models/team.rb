# frozen_string_literal: true

class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :organization

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :projects, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :set_defaults

  # Scopes
  scope :for_user, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }
  scope :search, ->(q) { where("name ILIKE :q OR description ILIKE :q", q: "%#{q}%") }

  def owner
    memberships.find_by(role: "owner")&.user
  end

  def admins
    users.joins(:memberships).where(memberships: { role: %w[owner admin] })
  end

  private

  def set_defaults
    self.settings ||= {}
  end

  # Override FriendlyId to only generate slug when blank, not to resolve conflicts
  def should_generate_new_friendly_id?
    slug.blank?
  end
end
