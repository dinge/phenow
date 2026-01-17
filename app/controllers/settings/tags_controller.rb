# frozen_string_literal: true

module Settings
  class TagsController < ApplicationController
    include CrudController

    before_action :authenticate_user!

    private

    def grid_class
      Settings::TagsGrid
    end

    def resource_scope
      # Only show tags for current organization
      current_organization.tags.alphabetical
    end

    def build_resource(attrs = {})
      # Always build with current organization
      current_organization.tags.new(attrs)
    end

    def permitted_attributes
      [:name, :color]
    end

    def current_organization
      # TODO: This should come from authentication/session
      # For now, return the first organization for testing
      @current_organization ||= Organization.first
    end
  end
end
