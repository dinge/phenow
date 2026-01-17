# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :organizations, through: :teams

  has_many :observations, foreign_key: :observed_by_id, dependent: :nullify, inverse_of: :observed_by
  has_many :selections, foreign_key: :selected_by_id, dependent: :nullify, inverse_of: :selected_by
  has_many :photos, foreign_key: :taken_by_id, dependent: :nullify, inverse_of: :taken_by
  has_many :comments, dependent: :destroy
  has_many :plant_stage_transitions, foreign_key: :recorded_by_id, dependent: :nullify, inverse_of: :recorded_by

  # Validations
  validates :name, presence: true
  validates :timezone, presence: true

  # Callbacks
  before_validation :set_defaults

  def display_name
    name.presence || email.split("@").first
  end

  private

  def set_defaults
    self.timezone ||= "UTC"
    self.preferences ||= {}
  end
end
