# frozen_string_literal: true

class Settings::TraitDefinitionsGrid
  include Datagrid

  scope do
    TraitDefinition.includes(:trait_category).all.ordered
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE ?", "%#{value}%")
  end

  filter(:data_type, :enum, select: TraitDefinition::DATA_TYPES.map { |t| [t.titleize, t] })

  column(:name, order: "name") do |trait_definition|
    format(trait_definition.name) do |value|
      content_tag(:strong, value)
    end
  end

  column(:trait_category_name, header: "Category", order: false) do |trait_definition|
    trait_definition.trait_category.name
  end

  column(:data_type, header: "Data Type", order: "data_type") do |trait_definition|
    content_tag(:span, trait_definition.data_type.titleize, class: "badge-info")
  end

  column(:unit, order: false)

  column(:range, header: "Range", order: false) do |trait_definition|
    if trait_definition.min_value || trait_definition.max_value
      "#{trait_definition.min_value}-#{trait_definition.max_value}"
    end
  end

  column(:stages, header: "Stages", order: false) do |trait_definition|
    if trait_definition.applicable_stages.any?
      "#{trait_definition.applicable_stages.count} stages"
    else
      "All stages"
    end
  end

  column(:type, header: "Type", order: false) do |trait_definition|
    if trait_definition.system_default?
      content_tag(:span, "System", class: "badge-info")
    else
      content_tag(:span, "Custom", class: "badge-success")
    end
  end

  column(:actions, html: true, order: false) do |trait_definition|
    unless trait_definition.system_default?
      edit_link = link_to("Edit", [:edit, :settings, trait_definition], class: "btn-ghost btn-sm")
      delete_button = button_to("Delete", [:settings, trait_definition],
        method: :delete,
        class: "btn-ghost btn-sm btn-danger-ghost",
        form: { data: { turbo_confirm: "Delete this trait definition?" } })

      content_tag(:div, edit_link + delete_button, class: "table-actions")
    end
  end
end
