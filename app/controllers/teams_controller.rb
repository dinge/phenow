# frozen_string_literal: true

class TeamsController < ApplicationController
  include CrudController

  before_action :authenticate_user!
  before_action :set_team_context, only: %i[new edit update]

  # Override create to handle membership creation
  def create
    @resource = build_resource(resource_params)
    if @resource.save
      # Create owner membership for current user
      @resource.memberships.create!(user: current_user, role: "owner")
      redirect_to after_save_path, notice: t(".success", default: "Created successfully.")
    else
      set_team_context
      render :new, status: :unprocessable_entity
    end
  end

  # Override update to set team context on failure
  def update
    if @resource.update(resource_params)
      redirect_to after_save_path, notice: t(".success", default: "Updated successfully.")
    else
      set_team_context
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Scope to current user's teams
  def resource_scope
    Team.for_user(current_user)
  end

  # Build resource with current organization
  def build_resource(attrs = {})
    current_organization.teams.new(attrs)
  end

  # Define permitted attributes
  def permitted_attributes
    %i[name description settings]
  end

  # Set @team for sidebar context
  def set_team_context
    @team = @resource || resource
  end

  # Get current organization from user's first team
  # In a real app, this would be more sophisticated (e.g., session-based)
  def current_organization
    @current_organization ||= begin
      # Get organization from user's teams, or fallback to first organization
      first_team = current_user.teams.first
      first_team&.organization || Organization.first
    end
  end
end
