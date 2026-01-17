# frozen_string_literal: true

class Settings::TraitCategoriesGrid
  include Datagrid

  scope do
    TraitCategory.all.ordered
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE ?", "%#{value}%")
  end

  column(:name, order: "name") do |trait_category|
    format(trait_category.name) do |value|
      content_tag(:strong, value)
    end
  end

  column(:description, order: false) do |trait_category|
    truncate(trait_category.description, length: 60) if trait_category.description.present?
  end

  column(:icon, order: false)

  column(:display_order, header: "Order", order: "display_order")

  column(:trait_definitions_count, header: "Traits", order: false) do |trait_category|
    trait_category.trait_definitions.count
  end

  column(:type, header: "Type", order: false) do |trait_category|
    if trait_category.system_default?
      content_tag(:span, "System", class: "badge-info")
    else
      content_tag(:span, "Custom", class: "badge-success")
    end
  end

  column(:actions, html: true, order: false) do |trait_category|
    unless trait_category.system_default?
      edit_link = link_to("Edit", [:edit, :settings, trait_category], class: "btn-ghost btn-sm")
      delete_button = button_to("Delete", [:settings, trait_category],
        method: :delete,
        class: "btn-ghost btn-sm btn-danger-ghost",
        form: { data: { turbo_confirm: "Delete this category? All custom trait definitions will also be deleted." } })

      content_tag(:div, edit_link + delete_button, class: "table-actions")
    end
  end
end
