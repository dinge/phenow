# frozen_string_literal: true

class TraitValue < ApplicationRecord
  # Associations
  belongs_to :observation
  belongs_to :trait_definition

  # Delegations
  delegate :data_type, :name, :unit, to: :trait_definition, prefix: :trait
  delegate :plant, :observed_by, to: :observation
  alias_method :user, :observed_by

  # Validations
  validates :trait_definition_id, uniqueness: { scope: :observation_id }

  # Returns the value based on the trait's data type
  def value
    case trait_definition.data_type
    when "numeric", "scale"
      numeric_value
    when "boolean"
      boolean_value
    when "select", "text"
      text_value
    end
  end

  # Sets the value based on the trait's data type
  def value=(val)
    case trait_definition.data_type
    when "numeric", "scale"
      self.numeric_value = val
    when "boolean"
      self.boolean_value = val
    when "select", "text"
      self.text_value = val
    end
  end

  def display_value
    return nil if value.nil?

    case trait_definition.data_type
    when "numeric"
      unit = trait_definition.unit
      unit.present? ? "#{value} #{unit}" : value.to_s
    when "scale"
      labels = trait_definition.scale_labels || {}
      labels[value.to_i.to_s] || value.to_s
    when "boolean"
      value ? "Yes" : "No"
    else
      value.to_s
    end
  end
end
