# frozen_string_literal: true

class Settings::TagsGrid
  include Datagrid

  scope do
    Tag.all.order(:name)
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE ?", "%#{value}%")
  end

  column(:name, order: "name") do |tag|
    format(tag.name) do |value|
      content_tag(:strong, value)
    end
  end

  column(:color, order: false) do |tag|
    format(tag.color) do |value|
      color_preview = content_tag(:span, "", class: "tag-preview",
        style: "background-color: #{value}; display: inline-block; width: 40px; height: 20px; border-radius: 4px;")
      color_code = content_tag(:code, value, class: "tag-color-code")
      color_preview + " " + color_code
    end
  end

  column(:tagged_count, header: "Tagged Items", order: false)

  column(:actions, html: true, order: false) do |tag|
    edit_link = link_to("Edit", [:edit, :settings, tag], class: "btn-ghost btn-sm")
    delete_button = button_to("Delete", [:settings, tag],
      method: :delete,
      class: "btn-ghost btn-sm btn-danger-ghost",
      form: { data: { turbo_confirm: "Delete this tag? It will be removed from all tagged items." } })

    content_tag(:div, edit_link + delete_button, class: "table-actions")
  end
end
