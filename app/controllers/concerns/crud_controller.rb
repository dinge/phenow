# frozen_string_literal: true

module CrudController
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i[show edit update destroy]
    before_action :set_collection, only: :index
    helper_method :resource, :collection, :resource_class, :resource_name
  end

  # ============================================
  # CRUD ACTIONS
  # ============================================

  def index
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    # Redirect to edit - no separate show view
    redirect_to edit_resource_path
  end

  def new
    @resource = build_resource
  end

  def create
    @resource = build_resource(resource_params)
    if @resource.save
      redirect_to after_save_path, notice: t(".success", default: "Created successfully.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Resource set by before_action
  end

  def update
    if @resource.update(resource_params)
      redirect_to after_save_path, notice: t(".success", default: "Updated successfully.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to after_destroy_path, notice: t(".success", default: "Deleted successfully.")
  end

  private

  # ============================================
  # HELPER METHODS (endless syntax)
  # ============================================

  def resource_class = controller_name.classify.constantize
  def resource_name = resource_class.model_name.singular
  def collection_name = resource_class.model_name.plural
  def resource = @resource
  def collection = @collection
  def resource_scope = resource_class.all
  def after_save_path = url_for(action: :index)
  def after_destroy_path = url_for(action: :index)

  def grid_class
    "#{controller_name.classify}Grid".constantize
  rescue NameError
    nil
  end

  def grid_params
    # Datagrid accepts filter params directly
    params.to_unsafe_h
  end

  # ============================================
  # BEFORE ACTIONS
  # ============================================

  def set_resource
    @resource = find_resource
    authorize @resource if respond_to?(:authorize, true)
  end

  def find_resource
    # Try friendly_id first, fall back to regular find
    resource_scope.friendly.find(params[:id])
  rescue NoMethodError
    # Model doesn't use friendly_id
    resource_scope.find(params[:id])
  end

  def build_resource(attrs = {})
    resource_scope.new(attrs)
  end

  def set_collection
    # Try to use datagrid if a grid class exists
    if grid_class.present?
      @grid = grid_class.new(grid_params)
      @grid = @grid.scope { resource_scope }
      @pagy, @collection = pagy(@grid.assets)
    else
      # Fallback to manual filtering/sorting
      scope = resource_scope
      scope = apply_filters(scope)
      scope = apply_search(scope)
      scope = apply_sorting(scope)
      @pagy, @collection = pagy(scope)
    end
  end

  # ============================================
  # FILTERING, SEARCH, SORTING
  # ============================================

  def apply_filters(scope)
    # Override in subclass
    scope
  end

  def apply_search(scope)
    return scope unless params[:q].present?

    # Requires .search scope on model
    scope.search(params[:q])
  end

  def apply_sorting(scope)
    return scope unless params[:sort].present?

    direction = params[:dir] == "desc" ? :desc : :asc
    scope.order(params[:sort] => direction)
  end

  # ============================================
  # PARAMS
  # ============================================

  def edit_resource_path
    url_for(action: :edit, id: @resource)
  end

  def resource_params
    params.require(resource_name).permit(permitted_attributes)
  end

  def permitted_attributes
    raise NotImplementedError, "Define #permitted_attributes in #{self.class}"
  end
end
