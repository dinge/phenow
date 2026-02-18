# frozen_string_literal: true

module NavigationHelper
  # Renders a navigation link with active state detection
  # @param label [String] The text to display
  # @param path [String] The path to link to
  # @return [String] HTML link tag with appropriate class
  def nav_link(label, path)
    css_class = current_page?(path) ? "nav-link-active" : "nav-link"
    link_to label, path, class: css_class
  end

  # Renders a sidebar link with active state detection
  # @param label [String] The text to display
  # @param path [String] The path to link to
  # @param icon [String, nil] Optional icon class or SVG
  # @return [String] HTML link tag with appropriate class
  def sidebar_link(label, path, icon: nil)
    css_class = current_page?(path) ? "sidebar-link-active" : "sidebar-link"

    link_to path, class: css_class do
      if icon.present?
        concat content_tag(:span, icon, class: "mr-2")
      end
      concat label
    end
  end
end
