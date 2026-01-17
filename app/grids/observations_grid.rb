# frozen_string_literal: true

class ObservationsGrid
  include Datagrid

  scope do
    Observation.includes(:plant, :observed_by, :trait_values, :photos).order(observed_at: :desc)
  end

  filter(:search, :string, header: "Search") do |value|
    where("notes ILIKE :q", q: "%#{value}%")
  end

  filter(:stage, :enum, select: Plant::STAGES)
  filter(:plant_id, :enum, select: -> { Plant.order(:identifier).pluck(:identifier, :id) }, header: "Plant")

  column(:observed_at, header: "Date", order: "observed_at") do |observation|
    observation.observed_at.strftime("%b %d, %Y")
  end

  column(:plant, order: false) do |observation|
    observation.plant.identifier
  end

  column(:stage, order: "stage") do |observation|
    if observation.stage.present?
      content_tag(:span, observation.stage.humanize, class: "badge badge-secondary")
    else
      "—"
    end
  end

  column(:overall_score, header: "Score", order: "overall_score") do |observation|
    if observation.overall_score.present?
      content_tag(:span, "#{observation.overall_score}/10", class: "badge badge-#{score_color(observation.overall_score)}")
    else
      "—"
    end
  end

  column(:trait_values_count, header: "Traits", order: false) do |observation|
    observation.trait_values.count
  end

  column(:photos_count, header: "Photos", order: false) do |observation|
    observation.photos.count
  end

  column(:observer, header: "Observer", order: false) do |observation|
    observation.observed_by.email
  end

  column(:actions) do |observation|
    # Actions will be rendered by the view
  end

  private

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
