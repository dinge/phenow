# frozen_string_literal: true

class StrainsGrid
  include Datagrid

  scope do
    Strain.includes(:organization).order(created_at: :desc)
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE :q OR breeder ILIKE :q OR COALESCE(description, '') ILIKE :q", q: "%#{value}%")
  end

  filter(:strain_type, :enum, select: Strain::STRAIN_TYPES, header: "Type")
  filter(:genetics_type, :enum, select: Strain::GENETICS_TYPES, header: "Genetics")
  filter(:verified, :boolean)

  column(:name, order: "name") do |strain|
    strain.name
  end

  column(:breeder, order: "breeder") do |strain|
    strain.breeder.presence || "—"
  end

  column(:strain_type, header: "Type", order: "strain_type") do |strain|
    if strain.strain_type.present?
      content_tag(:span, strain.strain_type.capitalize, class: "badge badge-#{strain_type_color(strain.strain_type)}")
    else
      "—"
    end
  end

  column(:genetics_type, header: "Genetics", order: "genetics_type") do |strain|
    if strain.genetics_type.present?
      content_tag(:span, strain.genetics_type.capitalize, class: "badge badge-secondary")
    else
      "—"
    end
  end

  column(:verified, order: "verified") do |strain|
    strain.verified ? "✓" : ""
  end

  column(:projects_count, header: "Projects") do |strain|
    strain.projects.count
  end

  column(:actions) do |strain|
    # Actions will be rendered by the view
  end

  private

  def strain_type_color(type)
    case type
    when "indica"
      "purple"
    when "sativa"
      "green"
    when "hybrid"
      "blue"
    when "ruderalis"
      "yellow"
    else
      "gray"
    end
  end
end
