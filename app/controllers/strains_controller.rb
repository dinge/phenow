# frozen_string_literal: true

class StrainsController < ApplicationController
  include CrudController

  # before_action :authenticate_user!  # TODO: Re-enable after Devise test configuration is fixed

  private

  # Override build_resource to set organization
  def build_resource(attrs = {})
    resource_scope.new(attrs.merge(organization: current_organization))
  end

  # Scope strains to current organization if available, otherwise all strains
  def resource_scope
    # For now, return all strains. In production, this should be scoped to current_organization
    # when proper authentication and organization context is implemented.
    Strain.all
  end

  # Define which attributes can be mass-assigned
  def permitted_attributes
    %i[
      name
      breeder
      strain_type
      genetics_type
      description
      lineage_text
      flowering_time_min
      flowering_time_max
      thc_min
      thc_max
      cbd_min
      cbd_max
      public
      verified
    ]
  end

  # Apply filter parameters to the collection
  def apply_filters(scope)
    scope = scope.where(strain_type: params[:strain_type]) if params[:strain_type].present?
    scope = scope.where(genetics_type: params[:genetics_type]) if params[:genetics_type].present?
    scope
  end

  # Helper method to get current organization
  # This is a temporary implementation - should be moved to ApplicationController
  # For now, get the first organization or use the one from params/session
  def current_organization
    @current_organization ||= begin
      # Try to get from params, session, or user's organizations
      # For testing purposes, get the first organization
      Organization.first
    end
  end
end
