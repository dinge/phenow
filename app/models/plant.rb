# frozen_string_literal: true

class Plant < ApplicationRecord
  SOURCE_TYPES = %w[seed clone].freeze
  SEXES = %w[unknown female male hermaphrodite].freeze
  STAGES = %w[germination seedling vegetative pre_flower flowering flush harvest drying curing testing].freeze
  STATUSES = %w[active keeper culled harvested archived].freeze

  # Associations
  belongs_to :project
  belongs_to :strain, optional: true
  belongs_to :source_plant, class_name: "Plant", optional: true

  has_many :clones, class_name: "Plant", foreign_key: :source_plant_id,
           dependent: :nullify, inverse_of: :source_plant

  has_many :observations, dependent: :destroy
  has_many :lab_tests, dependent: :destroy
  has_many :selections, dependent: :destroy
  has_many :stage_transitions, class_name: "PlantStageTransition", dependent: :destroy

  # Polymorphic
  has_many :photos, as: :photographable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  # Delegations
  delegate :team, :organization, to: :project

  # Validations
  validates :identifier, presence: true, uniqueness: { scope: :project_id }
  validates :source_type, presence: true, inclusion: { in: SOURCE_TYPES }
  validates :sex, inclusion: { in: SEXES }, allow_blank: true
  validates :current_stage, inclusion: { in: STAGES }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :keepers, -> { where(status: "keeper") }
  scope :culled, -> { where(status: "culled") }
  scope :females, -> { where(sex: "female") }
  scope :males, -> { where(sex: "male") }
  scope :in_stage, ->(stage) { where(current_stage: stage) }

  # Callbacks
  before_validation :set_defaults
  after_save :record_stage_transition, if: :saved_change_to_current_stage?

  def display_name
    name.presence || "#{project.strain&.name || 'Plant'} #{identifier}"
  end

  def keeper?
    status == "keeper"
  end

  def culled?
    status == "culled"
  end

  def female?
    sex == "female"
  end

  def male?
    sex == "male"
  end

  def days_in_veg
    return nil unless germination_date

    end_date = flip_date || Date.current
    (end_date - germination_date).to_i
  end

  def days_in_flower
    return nil unless flip_date

    end_date = harvest_date || Date.current
    (end_date - flip_date).to_i
  end

  def total_grow_days
    return nil unless germination_date

    end_date = harvest_date || Date.current
    (end_date - germination_date).to_i
  end

  def latest_observation
    observations.order(observed_at: :desc).first
  end

  def latest_selection
    selections.order(selected_at: :desc).first
  end

  def primary_photo
    photos.find_by(is_primary: true) || photos.order(created_at: :desc).first
  end

  def transition_to!(new_stage, recorded_by: nil, notes: nil)
    old_stage = current_stage
    update!(current_stage: new_stage)

    stage_transitions.create!(
      from_stage: old_stage,
      to_stage: new_stage,
      transitioned_at: Time.current,
      recorded_by: recorded_by,
      notes: notes
    )
  end

  private

  def set_defaults
    self.source_type ||= "seed"
    self.sex ||= "unknown"
    self.current_stage ||= "germination"
    self.status ||= "active"
    self.metadata ||= {}
  end

  def record_stage_transition
    return unless saved_change_to_current_stage?

    old_stage, new_stage = saved_change_to_current_stage
    stage_transitions.create!(
      from_stage: old_stage,
      to_stage: new_stage,
      transitioned_at: Time.current
    )
  end
end
