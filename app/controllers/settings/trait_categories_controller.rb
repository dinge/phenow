# frozen_string_literal: true

module Settings
  class TraitCategoriesController < ApplicationController
    include CrudController

    before_action :authenticate_user!
    before_action :prevent_system_modification, only: [:edit, :update, :destroy]

    private

    def resource_scope
      # Show both system defaults and org-specific categories
      TraitCategory.for_organization(current_organization).ordered
    end

    def build_resource(attrs = {})
      # Always build with current organization
      current_organization.trait_categories.new(attrs)
    end

    def permitted_attributes
      [:name, :description, :icon, :display_order]
    end

    def current_organization
      # TODO: This should come from authentication/session
      # For now, return the first organization for testing
      @current_organization ||= Organization.first
    end

    def prevent_system_modification
      if @resource.system_default?
        redirect_to settings_trait_categories_url, alert: "Cannot modify system default categories."
      end
    end
  end
end
