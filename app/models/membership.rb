# frozen_string_literal: true

class Membership < ApplicationRecord
  ROLES = %w[owner admin member viewer].freeze

  # Associations
  belongs_to :user
  belongs_to :team

  # Validations
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :team_id, message: "is already a member of this team" }

  # Scopes
  scope :owners, -> { where(role: "owner") }
  scope :admins, -> { where(role: %w[owner admin]) }
  scope :members, -> { where(role: %w[owner admin member]) }

  # Callbacks
  before_validation :set_default_role

  def owner?
    role == "owner"
  end

  def admin?
    role.in?(%w[owner admin])
  end

  def can_edit?
    role.in?(%w[owner admin member])
  end

  private

  def set_default_role
    self.role ||= "member"
  end
end
