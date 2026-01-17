# frozen_string_literal: true

class PlantsGrid
  include Datagrid

  scope do
    Plant.includes(:project, :strain, :observations, :selections).order(created_at: :desc)
  end

  filter(:search, :string, header: "Search") do |value|
    where("identifier ILIKE :q OR name ILIKE :q OR notes ILIKE :q", q: "%#{value}%")
  end

  filter(:status, :enum, select: Plant::STATUSES)
  filter(:current_stage, :enum, select: Plant::STAGES, header: "Stage")
  filter(:sex, :enum, select: Plant::SEXES)
  filter(:strain_id, :enum, select: -> { Strain.order(:name).pluck(:name, :id) }, header: "Strain")

  column(:identifier, order: "identifier") do |plant|
    plant.identifier
  end

  column(:name, order: "name") do |plant|
    plant.name.presence || "—"
  end

  column(:strain, order: false) do |plant|
    plant.strain&.name || plant.project.strain&.name || "—"
  end

  column(:sex, order: "sex") do |plant|
    if plant.sex.present? && plant.sex != "unknown"
      content_tag(:span, plant.sex.capitalize, class: "badge badge-#{sex_color(plant.sex)}")
    else
      "—"
    end
  end

  column(:current_stage, header: "Stage", order: "current_stage") do |plant|
    if plant.current_stage.present?
      content_tag(:span, plant.current_stage.humanize, class: "badge badge-secondary")
    else
      "—"
    end
  end

  column(:status, order: "status") do |plant|
    content_tag(:span, plant.status.capitalize, class: "badge badge-#{status_color(plant.status)}")
  end

  column(:days_in_flower, header: "Days Flower", order: false) do |plant|
    plant.days_in_flower || "—"
  end

  column(:observations_count, header: "Obs.", order: false) do |plant|
    plant.observations.count
  end

  column(:actions) do |plant|
    # Actions will be rendered by the view
  end

  private

  def status_color(status)
    case status
    when "active"
      "blue"
    when "keeper"
      "green"
    when "culled"
      "red"
    when "harvested"
      "purple"
    when "archived"
      "gray"
    else
      "gray"
    end
  end

  def sex_color(sex)
    case sex
    when "female"
      "pink"
    when "male"
      "blue"
    when "hermaphrodite"
      "purple"
    else
      "gray"
    end
  end
end
