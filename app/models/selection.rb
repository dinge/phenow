# frozen_string_literal: true

class Selection < ApplicationRecord
  DECISIONS = %w[keep cull breeding_mother breeding_father further_evaluation].freeze

  # Associations
  belongs_to :plant
  belongs_to :selected_by, class_name: "User", inverse_of: :selections

  # Polymorphic
  has_many :comments, as: :commentable, dependent: :destroy

  # Delegations
  delegate :project, :team, :organization, to: :plant

  # Validations
  validates :decision, presence: true, inclusion: { in: DECISIONS }
  validates :selected_at, presence: true
  validates :reasoning, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true

  # Scopes
  scope :search, ->(query) {
    where("reasoning ILIKE :q", q: "%#{query}%")
  }
  scope :chronological, -> { order(selected_at: :asc) }
  scope :reverse_chronological, -> { order(selected_at: :desc) }
  scope :keepers, -> { where(decision: "keep") }
  scope :culled, -> { where(decision: "cull") }
  scope :breeding_stock, -> { where(decision: %w[breeding_mother breeding_father]) }

  # Callbacks
  before_validation :set_defaults
  after_create :update_plant_status

  def keeper?
    decision == "keep"
  end

  def culled?
    decision == "cull"
  end

  def breeding_stock?
    decision.in?(%w[breeding_mother breeding_father])
  end

  private

  def set_defaults
    self.selected_at ||= Time.current
    self.standout_traits ||= []
    self.concerns ||= []
  end

  def update_plant_status
    new_status = case decision
                 when "keep", "breeding_mother", "breeding_father"
                   "keeper"
                 when "cull"
                   "culled"
                 else
                   plant.status
                 end

    plant.update!(status: new_status) if plant.status != new_status
  end
end
