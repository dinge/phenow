# frozen_string_literal: true

module Settings
  class TraitDefinitionsController < ApplicationController
    include CrudController

    before_action :authenticate_user!
    before_action :set_trait_category, only: [:new, :create]
    before_action :prevent_system_modification, only: [:edit, :update, :destroy]

    private

    def resource_scope
      # Show both system defaults and org-specific definitions
      scope = TraitDefinition.for_organization(current_organization).ordered

      # Filter by category if specified
      if params[:trait_category_id].present?
        category = TraitCategory.friendly.find(params[:trait_category_id])
        scope = scope.where(trait_category: category)
      end

      scope
    end

    def build_resource(attrs = {})
      # Build with current organization and trait category
      attrs[:trait_category_id] ||= @trait_category&.id
      current_organization.trait_definitions.new(attrs)
    end

    def permitted_attributes
      [
        :name, :description, :data_type, :unit,
        :min_value, :max_value, :display_order,
        :scale_labels, :options, :applicable_stages,
        :trait_category_id
      ]
    end

    def current_organization
      # TODO: This should come from authentication/session
      # For now, return the first organization for testing
      @current_organization ||= Organization.first
    end

    def set_trait_category
      if params[:trait_category_id].present?
        @trait_category = TraitCategory.friendly.find(params[:trait_category_id])
      end
    end

    def prevent_system_modification
      if @resource.system_default?
        redirect_to settings_trait_categories_url, alert: "Cannot modify system default trait definitions."
      end
    end

    def after_save_path
      settings_trait_categories_url
    end

    def after_destroy_path
      settings_trait_categories_url
    end
  end
end
