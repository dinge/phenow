# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_team

  include CrudController

  private

  def set_team
    @team = Team.friendly.find(params[:team_id])
  end

  def resource_scope
    @team.projects.includes(:strain)
  end

  def permitted_attributes
    %i[name description project_type status strain_id
       start_date target_end_date actual_end_date seed_count settings]
  end

  def apply_filters(scope)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(project_type: params[:project_type]) if params[:project_type].present?
    scope
  end

  def after_save_path
    team_projects_path(@team)
  end

  def after_destroy_path
    team_projects_path(@team)
  end
end
