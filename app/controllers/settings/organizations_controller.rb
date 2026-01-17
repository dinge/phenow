# frozen_string_literal: true

module Settings
  class OrganizationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_resource, only: %i[show edit update]

    # GET /settings/organization
    def show
      redirect_to edit_settings_organization_url
    end

    # GET /settings/organization/edit
    def edit
      # Resource set by before_action
    end

    # PATCH/PUT /settings/organization
    def update
      if @resource.update(resource_params)
        redirect_to edit_settings_organization_url, notice: t(".success", default: "Organization updated successfully.")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_resource
      @resource = current_organization
    end

    def resource
      @resource
    end
    helper_method :resource

    def resource_params
      params.require(:organization).permit(permitted_attributes)
    end

    def permitted_attributes
      [:name, :slug, settings: {}]
    end

    def current_organization
      # TODO: This should come from authentication/session
      # For now, return the first organization for testing
      @current_organization ||= Organization.first
    end
  end
end
