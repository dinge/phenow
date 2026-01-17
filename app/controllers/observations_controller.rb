# frozen_string_literal: true

class ObservationsController < ApplicationController
  include CrudController

  prepend_before_action :authenticate_user!
  prepend_before_action :set_plant, only: %i[index new create]
  before_action :set_plant_from_resource, only: %i[edit update destroy]
  before_action :set_context

  # ============================================
  # RESOURCE CONFIGURATION
  # ============================================

  private

  def resource_scope
    if @plant
      @plant.observations
    else
      Observation.all
    end
  end

  def build_resource(attrs = {})
    obs = super(attrs)
    obs.observed_by = current_user if obs.new_record?
    obs
  end

  def permitted_attributes
    %i[observed_at stage overall_score notes week_number]
  end

  # ============================================
  # BEFORE ACTIONS
  # ============================================

  def set_plant
    @plant = Plant.find(params[:plant_id])
  end

  def set_plant_from_resource
    @plant = @resource.plant
  end

  def set_context
    if @plant
      @project = @plant.project
      @team = @plant.team
    elsif @resource
      @plant = @resource.plant
      @project = @plant.project
      @team = @plant.team
    end
  end

  # ============================================
  # FILTERS & SORTING
  # ============================================

  def apply_filters(scope)
    scope = scope.in_stage(params[:stage]) if params[:stage].present?
    scope
  end

  def apply_sorting(scope)
    return super if params[:sort].present?

    # Default to chronological order (oldest first)
    scope.chronological
  end

  # ============================================
  # REDIRECTS
  # ============================================

  def after_save_path
    plant = @plant || @resource.plant
    team_project_plant_observations_path(plant.team, plant.project, plant)
  end

  def after_destroy_path
    plant = @resource.plant
    team_project_plant_observations_path(plant.team, plant.project, plant)
  end
end
