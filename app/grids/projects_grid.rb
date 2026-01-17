# frozen_string_literal: true

class ProjectsGrid
  include Datagrid

  scope do
    Project.includes(:team, :strain, :plants).order(created_at: :desc)
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE :q OR description ILIKE :q", q: "%#{value}%")
  end

  filter(:status, :enum, select: Project::STATUSES)
  filter(:project_type, :enum, select: Project::PROJECT_TYPES, header: "Type")

  column(:name, order: "name") do |project|
    project.name
  end

  column(:strain, order: false) do |project|
    project.strain&.name || "—"
  end

  column(:project_type, header: "Type", order: "project_type") do |project|
    content_tag(:span, project.project_type.capitalize, class: "badge badge-secondary")
  end

  column(:status, order: "status") do |project|
    content_tag(:span, project.status.capitalize, class: "badge badge-#{status_color(project.status)}")
  end

  column(:plant_count, header: "Plants", order: false) do |project|
    project.plants.count
  end

  column(:keeper_count, header: "Keepers", order: false) do |project|
    project.keeper_count
  end

  column(:completion, header: "Progress", order: false) do |project|
    "#{project.completion_percentage}%"
  end

  column(:created_at, header: "Created", order: "created_at") do |project|
    project.created_at.strftime("%b %d, %Y")
  end

  column(:actions) do |project|
    # Actions will be rendered by the view
  end

  private

  def status_color(status)
    case status
    when "planning"
      "gray"
    when "active"
      "green"
    when "completed"
      "blue"
    when "archived"
      "yellow"
    else
      "gray"
    end
  end
end
