# frozen_string_literal: true

class Photo < ApplicationRecord
  PHOTO_TYPES = %w[whole_plant bud trichome leaf environment other].freeze

  # ActiveStorage
  has_one_attached :image

  # Associations
  belongs_to :photographable, polymorphic: true
  belongs_to :taken_by, class_name: "User", optional: true, inverse_of: :photos

  # Validations
  validates :image, presence: true, on: :create
  validates :photo_type, inclusion: { in: PHOTO_TYPES }, allow_blank: true
  validates :stage, inclusion: { in: Plant::STAGES }, allow_blank: true

  # Scopes
  scope :primary, -> { where(is_primary: true) }
  scope :by_type, ->(type) { where(photo_type: type) }
  scope :for_stage, ->(stage) { where(stage: stage) }
  scope :chronological, -> { order(taken_at: :asc, created_at: :asc) }
  scope :reverse_chronological, -> { order(taken_at: :desc, created_at: :desc) }
  scope :recent, -> { order(taken_at: :desc, created_at: :desc) }

  # Callbacks
  before_validation :set_defaults

  def thumbnail
    image.variant(resize_to_limit: [200, 200])
  end

  def medium
    image.variant(resize_to_limit: [600, 600])
  end

  def large
    image.variant(resize_to_limit: [1200, 1200])
  end

  def plant
    case photographable_type
    when "Plant"
      photographable
    when "Observation"
      photographable.plant
    else
      nil
    end
  end

  private

  def set_defaults
    self.taken_at ||= Time.current
    self.is_primary ||= false
    self.metadata ||= {}
  end
end
