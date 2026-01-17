# frozen_string_literal: true

class StrainLineage < ApplicationRecord
  PARENT_ROLES = %w[mother father unknown].freeze

  # Associations
  belongs_to :child_strain, class_name: "Strain", inverse_of: :parent_lineages
  belongs_to :parent_strain, class_name: "Strain", inverse_of: :child_lineages

  # Validations
  validates :parent_role, presence: true, inclusion: { in: PARENT_ROLES }
  validates :parent_strain_id, uniqueness: { scope: :child_strain_id }
  validate :not_self_referencing

  private

  def not_self_referencing
    if child_strain_id == parent_strain_id
      errors.add(:parent_strain_id, "can't be the same as child strain")
    end
  end
end
