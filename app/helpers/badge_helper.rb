# frozen_string_literal: true

module BadgeHelper
  # Returns a badge span for plant status
  # Maps status to appropriate CSS modifier class
  #
  # @param status [String, Symbol] The plant status
  # @return [String] HTML span element with badge classes
  def status_badge(status)
    return unless status.present?

    status_str = status.to_s
    css_class = "badge-#{status_str.dasherize}"

    content_tag(:span, status_str.titleize, class: css_class)
  end

  # Returns a badge span for growth stage
  #
  # @param stage [String, Symbol] The growth stage
  # @return [String] HTML span element with badge classes
  def stage_badge(stage)
    return unless stage.present?

    stage_str = stage.to_s
    content_tag(:span, stage_str.titleize.gsub("_", " "), class: "badge-stage")
  end

  # Returns a badge span for selection decision
  #
  # @param decision [String, Symbol] The selection decision
  # @return [String] HTML span element with badge classes
  def decision_badge(decision)
    return unless decision.present?

    decision_str = decision.to_s
    css_class = "badge-#{decision_str.dasherize}"

    content_tag(:span, decision_str.titleize.gsub("_", " "), class: css_class)
  end
end
