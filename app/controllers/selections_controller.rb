# frozen_string_literal: true

class SelectionsController < ApplicationController
  include CrudController

  before_action :authenticate_user!
  prepend_before_action :set_plant, only: %i[index new create]
  before_action :set_context

  private

  # ============================================
  # RESOURCE CONFIGURATION
  # ============================================

  def resource_scope
    if params[:plant_id]
      @plant.selections
    else
      # Shallow routes - get plant from selection
      Selection.all
    end
  end

  def permitted_attributes
    %i[
      decision
      reasoning
      selected_at
      score
    ]
  end

  def build_resource(attrs = {})
    resource = super(attrs)
    resource.selected_by = current_user
    resource
  end

  # ============================================
  # FILTERING & SEARCH
  # ============================================

  def apply_filters(scope)
    scope = super(scope)
    scope = scope.where(decision: params[:decision]) if params[:decision].present?
    scope
  end

  # ============================================
  # BEFORE ACTIONS
  # ============================================

  def set_plant
    @plant = Plant.find(params[:plant_id])
  end

  def set_context
    # For shallow routes, get context from the selection
    if @resource && !@plant
      @plant = @resource.plant
    end

    @project = @plant&.project
    @team = @project&.team
  end

  # ============================================
  # REDIRECT PATHS
  # ============================================

  def after_save_path
    team_project_plant_selections_path(@team, @project, @plant)
  end

  def after_destroy_path
    team_project_plant_selections_path(@team, @project, @plant)
  end
end
