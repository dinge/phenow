# frozen_string_literal: true

class SelectionsGrid
  include Datagrid

  scope do
    Selection.includes(:plant, :selected_by).order(selected_at: :desc)
  end

  filter(:search, :string, header: "Search") do |value|
    where("reasoning ILIKE :q", q: "%#{value}%")
  end

  filter(:decision, :enum, select: Selection::DECISIONS)
  filter(:plant_id, :enum, select: -> { Plant.order(:identifier).pluck(:identifier, :id) }, header: "Plant")

  column(:selected_at, header: "Date", order: "selected_at") do |selection|
    selection.selected_at.strftime("%b %d, %Y")
  end

  column(:plant, order: false) do |selection|
    selection.plant.identifier
  end

  column(:decision, order: "decision") do |selection|
    content_tag(:span, selection.decision.humanize, class: "badge badge-#{decision_color(selection.decision)}")
  end

  column(:score, order: "score") do |selection|
    if selection.score.present?
      content_tag(:span, "#{selection.score}/10", class: "badge badge-#{score_color(selection.score)}")
    else
      "—"
    end
  end

  column(:reasoning, order: false) do |selection|
    truncate(selection.reasoning, length: 80)
  end

  column(:selected_by, header: "Selected By", order: false) do |selection|
    selection.selected_by.email
  end

  column(:actions) do |selection|
    # Actions will be rendered by the view
  end

  private

  def decision_color(decision)
    case decision
    when "keep", "breeding_mother", "breeding_father"
      "green"
    when "cull"
      "red"
    when "further_evaluation"
      "yellow"
    else
      "gray"
    end
  end

  def score_color(score)
    case score
    when 8..10
      "green"
    when 6..7
      "blue"
    when 4..5
      "yellow"
    else
      "red"
    end
  end
end
