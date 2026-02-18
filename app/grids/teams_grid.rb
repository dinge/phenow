# frozen_string_literal: true

class TeamsGrid
  include Datagrid

  scope do
    Team.includes(:memberships, :users).order(created_at: :desc)
  end

  filter(:name, :string, header: "Search") do |value|
    where("name ILIKE :q OR description ILIKE :q", q: "%#{value}%")
  end

  column(:name, order: "name") do |team|
    team.name
  end

  column(:description, order: false) do |team|
    if team.description.present?
      truncate(team.description, length: 100)
    else
      "—"
    end
  end

  column(:member_count, header: "Members", order: false) do |team|
    team.memberships.count
  end

  column(:projects_count, header: "Projects", order: false) do |team|
    team.projects.count
  end

  column(:owner, order: false) do |team|
    owner = team.owner
    owner ? owner.email : "—"
  end

  column(:created_at, header: "Created", order: "created_at") do |team|
    team.created_at.strftime("%b %d, %Y")
  end

  column(:actions) do |team|
    # Actions will be rendered by the view
  end
end
