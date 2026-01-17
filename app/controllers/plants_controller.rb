# frozen_string_literal: true

class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :set_project

  include CrudController

  private

  def set_team
    @team = Team.friendly.find(params[:team_id])
  end

  def set_project
    @project = @team.projects.friendly.find(params[:project_id])
  end

  def resource_scope
    @project.plants.includes(:strain)
  end

  def permitted_attributes
    %i[
      identifier
      name
      strain_id
      source_type
      sex
      current_stage
      status
      germination_date
      flip_date
      harvest_date
      notes
    ]
  end

  def apply_filters(scope)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(current_stage: params[:stage]) if params[:stage].present?
    scope = scope.where(strain_id: params[:strain_id]) if params[:strain_id].present?
    scope
  end

  def after_save_path
    team_project_plants_path(@team, @project)
  end

  def after_destroy_path
    team_project_plants_path(@team, @project)
  end
end
