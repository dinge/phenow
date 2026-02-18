# frozen_string_literal: true

class PhotosController < ApplicationController
  include CrudController

  before_action :authenticate_user!
  # Use prepend to run before CrudController's set_collection
  prepend_before_action :set_plant, only: [:index, :new, :create]
  prepend_before_action :set_context_from_resource, only: [:edit, :update, :destroy]

  # ============================================
  # OVERRIDES FROM CrudController
  # ============================================

  def resource_scope
    if @plant
      # Nested route - scope to plant's photos
      @plant.photos
    else
      # Shallow route - find photo by ID and set context
      Photo.all
    end
  end

  def after_save_path
    if @plant
      team_project_plant_photos_path(@team, @project, @plant)
    else
      # After editing/updating via shallow route, redirect back to plant's photos
      team_project_plant_photos_path(@team, @project, @resource.photographable)
    end
  end

  def after_destroy_path
    team_project_plant_photos_path(@team, @project, @resource.photographable)
  end

  def build_resource(attrs = {})
    if @plant
      @plant.photos.new(attrs.merge(taken_by: current_user))
    else
      Photo.new(attrs)
    end
  end

  private

  # ============================================
  # BEFORE ACTIONS
  # ============================================

  def set_plant
    @plant = Plant.find(params[:plant_id])
    @project = @plant.project
    @team = @project.team
  end

  def set_context_from_resource
    # For shallow routes (edit, update, destroy), we need to set context from the photo's plant
    @resource = find_resource
    @plant = @resource.photographable if @resource.photographable_type == "Plant"
    @project = @plant&.project
    @team = @project&.team
  end

  # ============================================
  # FILTERING
  # ============================================

  def apply_filters(scope)
    scope = scope.by_type(params[:photo_type]) if params[:photo_type].present?
    scope = scope.where(stage: params[:stage]) if params[:stage].present?
    scope
  end

  # ============================================
  # SORTING
  # ============================================

  def apply_sorting(scope)
    # Default to reverse chronological (newest first)
    return scope.reverse_chronological unless params[:sort].present?

    # Allow custom sorting
    super
  end

  # ============================================
  # PARAMS
  # ============================================

  def permitted_attributes
    [:image, :caption, :taken_at, :photo_type, :stage, :is_primary]
  end
end
