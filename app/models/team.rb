# frozen_string_literal: true

class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :organization

  # Associations
  belongs_to :organization

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :projects, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id }

  # Callbacks
  before_validation :set_defaults

  # Scopes
  scope :for_user, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }

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
end
