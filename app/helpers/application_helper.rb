module ApplicationHelper
  include Pagy::Frontend

  # Determines if the sidebar should be shown
  # @return [Boolean] true if sidebar should be displayed
  def show_sidebar?
    # Show sidebar when viewing team or project contexts
    @team.present? || @project.present?
  end
end
