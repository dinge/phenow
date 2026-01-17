# frozen_string_literal: true

class PhotosGrid
  include Datagrid

  scope do
    Photo.includes(:photographable, :taken_by).order(taken_at: :desc, created_at: :desc)
  end

  filter(:search, :string, header: "Search") do |value|
    where("caption ILIKE :q", q: "%#{value}%")
  end

  filter(:photo_type, :enum, select: Photo::PHOTO_TYPES, header: "Type")
  filter(:stage, :enum, select: Plant::STAGES)
  filter(:is_primary, :boolean, header: "Primary Only")

  column(:thumbnail, order: false, html: true) do |photo|
    if photo.image.attached?
      image_tag(photo.thumbnail, alt: photo.caption, class: "w-12 h-12 object-cover rounded")
    else
      "—"
    end
  end

  column(:caption, order: "caption") do |photo|
    if photo.caption.present?
      truncate(photo.caption, length: 60)
    else
      "—"
    end
  end

  column(:photo_type, header: "Type", order: "photo_type") do |photo|
    if photo.photo_type.present?
      content_tag(:span, photo.photo_type.humanize, class: "badge badge-secondary")
    else
      "—"
    end
  end

  column(:stage, order: "stage") do |photo|
    if photo.stage.present?
      content_tag(:span, photo.stage.humanize, class: "badge badge-secondary")
    else
      "—"
    end
  end

  column(:photographable_type, header: "Subject", order: "photographable_type") do |photo|
    case photo.photographable_type
    when "Plant"
      "Plant: #{photo.photographable.identifier}"
    when "Observation"
      "Observation: #{photo.photographable.plant.identifier}"
    when "Strain"
      "Strain: #{photo.photographable.name}"
    when "Project"
      "Project: #{photo.photographable.name}"
    else
      photo.photographable_type
    end
  end

  column(:taken_at, header: "Taken", order: "taken_at") do |photo|
    photo.taken_at.strftime("%b %d, %Y")
  end

  column(:taken_by, header: "By", order: false) do |photo|
    photo.taken_by&.email || "—"
  end

  column(:is_primary, header: "Primary", order: "is_primary") do |photo|
    photo.is_primary ? "★" : ""
  end

  column(:actions) do |photo|
    # Actions will be rendered by the view
  end
end
