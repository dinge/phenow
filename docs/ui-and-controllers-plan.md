# UI & Controllers Implementation Plan

> A comprehensive plan for building Phenow's UI layer with minimal code, maximal reuse.

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Gems & Dependencies](#gems--dependencies)
3. [Controller Abstraction](#controller-abstraction)
4. [Shared View System](#shared-view-system)
5. [Navigation & Layout](#navigation--layout)
6. [List Views with Datagrid](#list-views-with-datagrid)
7. [Form System](#form-system)
8. [Turbo & Stimulus Patterns](#turbo--stimulus-patterns)
9. [Implementation Phases](#implementation-phases)
10. [File Structure](#file-structure)

---

## Architecture Overview

### Core Principles
- **DRY Controllers**: One concern handles 80% of CRUD logic
- **Data-Driven Views**: Shared partials configured via model metadata
- **Mobile-First**: Tailwind responsive design, touch-friendly
- **Turbo by Default**: Frame-based navigation, stream updates
- **Joy of Use**: Fast, intuitive, works in grow room conditions

### Key Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│                      CONTROLLER LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  ApplicationController                                           │
│    └── Concerns::CrudController (index, show, new, create, etc) │
│          └── TeamsController (inherits, overrides as needed)    │
│          └── ProjectsController                                  │
│          └── PlantsController                                    │
│          └── etc...                                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        VIEW LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  app/views/application/                                          │
│    ├── _index.html.erb      (shared list view template)         │
│    ├── _form.html.erb       (shared form template)              │
│    ├── _card.html.erb       (shared card component)             │
│    └── _filters.html.erb    (shared search/filter bar)          │
│                                                                  │
│  app/views/teams/                                                │
│    └── (only overrides if needed)                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Gems & Dependencies

### Required Gems (add to Gemfile)

```ruby
# UI & Forms
gem "simple_form"           # Cleaner form DSL
gem "pagy"                  # Fast pagination
gem "datagrid"              # Filterable/sortable tables

# Authorization
gem "pundit"                # Policy-based auth

# View helpers
gem "view_component"        # Optional: for complex UI components
```

### Already Included
- `devise` - Authentication
- `friendly_id` - Slugs
- `turbo-rails` - Hotwire Turbo
- `stimulus-rails` - Hotwire Stimulus
- `tailwindcss-rails` - Styling

---

## Controller Abstraction

### CrudController Concern

The heart of code reuse. Controllers include this concern and only override what's different.

```ruby
# app/controllers/concerns/crud_controller.rb
module CrudController
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :set_collection, only: [:index]
    helper_method :resource, :collection, :resource_class, :resource_name
  end

  # GET /resources
  def index
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /resources/:id
  def show
    redirect_to edit_resource_path(resource)  # No separate show view!
  end

  # GET /resources/new
  def new
    @resource = build_resource
  end

  # POST /resources
  def create
    @resource = build_resource(resource_params)
    if @resource.save
      respond_to do |format|
        format.html { redirect_to after_create_path, notice: "#{resource_name.humanize} created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /resources/:id/edit
  def edit; end

  # PATCH /resources/:id
  def update
    if @resource.update(resource_params)
      respond_to do |format|
        format.html { redirect_to after_update_path, notice: "#{resource_name.humanize} updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /resources/:id
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to after_destroy_path, notice: "#{resource_name.humanize} deleted." }
      format.turbo_stream
    end
  end

  private

  # Override in subclasses
  def resource_class
    controller_name.classify.constantize
  end

  def resource_name
    resource_class.model_name.singular
  end

  def collection_name
    resource_class.model_name.plural
  end

  def resource
    @resource
  end

  def collection
    @collection
  end

  def set_resource
    @resource = find_resource
  end

  def find_resource
    resource_scope.friendly.find(params[:id])
  rescue NoMethodError
    resource_scope.find(params[:id])
  end

  def resource_scope
    resource_class.all
  end

  def build_resource(attrs = {})
    resource_scope.new(attrs)
  end

  def set_collection
    @collection = filter_collection(resource_scope)
    @pagy, @collection = pagy(@collection)
  end

  def filter_collection(scope)
    # Datagrid filtering handled here
    if datagrid_class
      @grid = datagrid_class.new(params.fetch(:grid, {}).permit!)
      @grid.scope { scope }
      @grid.assets
    else
      scope
    end
  end

  def datagrid_class
    "#{resource_class}Grid".safe_constantize
  end

  def resource_params
    params.require(resource_name).permit(permitted_attributes)
  end

  def permitted_attributes
    raise NotImplementedError, "Define permitted_attributes in #{self.class}"
  end

  def after_create_path
    collection_path
  end

  def after_update_path
    collection_path
  end

  def after_destroy_path
    collection_path
  end

  def collection_path
    url_for(action: :index)
  end

  def edit_resource_path(res)
    url_for(action: :edit, id: res)
  end
end
```

### Example Controller (Minimal)

```ruby
# app/controllers/strains_controller.rb
class StrainsController < ApplicationController
  include CrudController

  private

  def resource_scope
    current_organization.strains
  end

  def permitted_attributes
    [:name, :breeder, :strain_type, :description, :lineage_text,
     :genetics_type, :flowering_time_min, :flowering_time_max,
     :thc_min, :thc_max, dominant_terpenes: [], effects: [], aromas: []]
  end
end
```

### Nested Resource Controllers

```ruby
# app/controllers/plants_controller.rb
class PlantsController < ApplicationController
  include CrudController

  before_action :set_project

  private

  def set_project
    @project = current_team.projects.friendly.find(params[:project_id])
  end

  def resource_scope
    @project.plants
  end

  def permitted_attributes
    [:identifier, :name, :strain_id, :source_type, :sex,
     :current_stage, :status, :germination_date, :flip_date,
     :harvest_date, :notes]
  end

  def after_create_path
    team_project_plants_path(current_team, @project)
  end
end
```

---

## Shared View System

### Directory Structure

```
app/views/
├── application/
│   ├── _index.html.erb         # Shared list view
│   ├── _form.html.erb          # Shared form wrapper
│   ├── _filters.html.erb       # Search/filter bar
│   ├── _pagination.html.erb    # Pagy pagination
│   ├── _card.html.erb          # Card component
│   ├── _empty_state.html.erb   # No results
│   ├── _flash.html.erb         # Flash messages
│   └── _modal.html.erb         # Modal wrapper
├── layouts/
│   ├── application.html.erb    # Main layout
│   └── _navbar.html.erb        # Navigation
└── [resource]/
    └── (only custom views)
```

### Model Metadata for Views

Each model defines its view configuration:

```ruby
# app/models/concerns/viewable.rb
module Viewable
  extend ActiveSupport::Concern

  class_methods do
    # Define columns for list view
    def list_columns
      [:id, :name, :created_at]  # Override in model
    end

    # Define form fields
    def form_fields
      []  # Override in model
    end

    # Search configuration
    def searchable_fields
      [:name]
    end
  end
end

# app/models/plant.rb
class Plant < ApplicationRecord
  include Viewable

  def self.list_columns
    [
      { field: :identifier, label: "ID", sortable: true },
      { field: :display_name, label: "Name" },
      { field: :strain, label: "Strain", association: true },
      { field: :current_stage, label: "Stage", badge: true },
      { field: :status, label: "Status", badge: true },
      { field: :days_in_flower, label: "Flower Days" }
    ]
  end

  def self.form_fields
    [
      { field: :identifier, type: :string, required: true },
      { field: :name, type: :string },
      { field: :strain_id, type: :association, collection: -> { Strain.all } },
      { field: :source_type, type: :select, options: SOURCE_TYPES },
      { field: :sex, type: :select, options: SEXES },
      { field: :current_stage, type: :select, options: STAGES },
      { field: :status, type: :select, options: STATUSES },
      { field: :germination_date, type: :date },
      { field: :flip_date, type: :date },
      { field: :notes, type: :text }
    ]
  end
end
```

### Shared Index Template

```erb
<%# app/views/application/_index.html.erb %>
<%= turbo_frame_tag "#{collection_name}_list" do %>
  <div class="space-y-4">
    <%# Header with title and new button %>
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold"><%= collection_name.humanize %></h1>
      <%= link_to "New #{resource_name.humanize}",
          url_for(action: :new),
          class: "btn btn-primary",
          data: { turbo_frame: "modal" } %>
    </div>

    <%# Filters %>
    <%= render "application/filters", grid: @grid if @grid %>

    <%# Table %>
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <% resource_class.list_columns.each do |col| %>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                <%= col[:label] || col[:field].to_s.humanize %>
              </th>
            <% end %>
            <th class="px-4 py-3"></th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <% collection.each do |item| %>
            <%= render "application/row", item: item, columns: resource_class.list_columns %>
          <% end %>
        </tbody>
      </table>
    </div>

    <%# Pagination %>
    <%= render "application/pagination", pagy: @pagy %>
  </div>
<% end %>
```

---

## Navigation & Layout

### Main Layout Structure

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html class="h-full">
<head>
  <%= render "layouts/head" %>
</head>
<body class="h-full bg-gray-100">
  <%# Mobile-first responsive layout %>
  <div class="min-h-full">
    <%# Navigation %>
    <%= render "layouts/navbar" %>

    <%# Sidebar (desktop) %>
    <div class="flex">
      <%= render "layouts/sidebar" %>

      <%# Main content %>
      <main class="flex-1 p-4 lg:p-8">
        <%= render "application/flash" %>

        <%# Turbo frame for main content %>
        <%= turbo_frame_tag "main_content" do %>
          <%= yield %>
        <% end %>
      </main>
    </div>
  </div>

  <%# Modal container %>
  <%= turbo_frame_tag "modal" %>
</body>
</html>
```

### Navbar Structure

```erb
<%# app/views/layouts/_navbar.html.erb %>
<nav class="bg-green-700 text-white">
  <div class="max-w-7xl mx-auto px-4">
    <div class="flex justify-between h-16">
      <%# Logo %>
      <div class="flex items-center">
        <%= link_to "Phenow", root_path, class: "text-xl font-bold" %>
      </div>

      <%# Desktop nav %>
      <div class="hidden md:flex items-center space-x-4">
        <%= nav_link "Dashboard", root_path %>
        <%= nav_link "Projects", teams_path %>
        <%= nav_link "Strains", strains_path %>
        <%= nav_link "Settings", settings_organization_path %>
      </div>

      <%# Mobile menu button %>
      <div class="md:hidden flex items-center">
        <button data-controller="mobile-menu" data-action="click->mobile-menu#toggle">
          <svg class="h-6 w-6" ...></svg>
        </button>
      </div>

      <%# User menu %>
      <div class="flex items-center">
        <%= render "layouts/user_menu" %>
      </div>
    </div>
  </div>
</nav>
```

### Sidebar Navigation (Context-Aware)

```erb
<%# app/views/layouts/_sidebar.html.erb %>
<aside class="hidden lg:block w-64 bg-white shadow-sm">
  <nav class="p-4 space-y-2">
    <% if @team %>
      <h3 class="text-sm font-semibold text-gray-500 uppercase">Team: <%= @team.name %></h3>
      <%= sidebar_link "Projects", team_projects_path(@team), icon: "folder" %>
      <%= sidebar_link "Members", team_memberships_path(@team), icon: "users" %>
    <% end %>

    <% if @project %>
      <h3 class="text-sm font-semibold text-gray-500 uppercase mt-6">Project: <%= @project.name %></h3>
      <%= sidebar_link "Plants", team_project_plants_path(@team, @project), icon: "seedling" %>
      <%= sidebar_link "Goals", team_project_project_goals_path(@team, @project), icon: "target" %>
    <% end %>
  </nav>
</aside>
```

---

## List Views with Datagrid

### Datagrid Configuration

```ruby
# app/grids/plants_grid.rb
class PlantsGrid
  include Datagrid

  scope { Plant.includes(:strain, :project) }

  # Filters (appear above table)
  filter(:identifier, :string, header: "Search ID") { |value, scope|
    scope.where("identifier ILIKE ?", "%#{value}%")
  }
  filter(:status, :enum, select: Plant::STATUSES, header: "Status")
  filter(:current_stage, :enum, select: Plant::STAGES, header: "Stage")
  filter(:sex, :enum, select: Plant::SEXES, header: "Sex")
  filter(:strain_id, :enum, select: -> { Strain.pluck(:name, :id) }, header: "Strain")

  # Columns
  column(:identifier, header: "ID", order: true)
  column(:display_name, header: "Name")
  column(:strain, header: "Strain") { |plant| plant.strain&.name }
  column(:current_stage, header: "Stage", order: true) { |plant|
    content_tag(:span, plant.current_stage.humanize,
                class: "badge badge-#{stage_color(plant.current_stage)}")
  }
  column(:status, header: "Status", order: true) { |plant|
    content_tag(:span, plant.status.humanize,
                class: "badge badge-#{status_color(plant.status)}")
  }
  column(:days_in_flower, header: "Days Flower")
  column(:actions, html: true, header: "") { |plant|
    render "shared/row_actions", resource: plant
  }
end
```

### Filters Partial

```erb
<%# app/views/application/_filters.html.erb %>
<%= form_with url: url_for, method: :get, data: { controller: "filters", turbo_frame: "#{collection_name}_list" } do %>
  <div class="bg-white p-4 rounded-lg shadow-sm mb-4">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <% grid.filters.each do |filter| %>
        <div>
          <%= label_tag "grid[#{filter.name}]", filter.header, class: "block text-sm font-medium text-gray-700" %>
          <%= datagrid_filter_input(grid, filter.name, class: "mt-1 input") %>
        </div>
      <% end %>
    </div>
    <div class="mt-4 flex justify-end space-x-2">
      <%= link_to "Clear", url_for, class: "btn btn-secondary" %>
      <%= submit_tag "Filter", class: "btn btn-primary" %>
    </div>
  </div>
<% end %>
```

---

## Form System

### Simple Form Configuration

```ruby
# config/initializers/simple_form.rb
SimpleForm.setup do |config|
  config.wrappers :default, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: "block text-sm font-medium text-gray-700 mb-1"
    b.use :input, class: "input w-full", error_class: "input-error"
    b.use :hint, wrap_with: { tag: :p, class: "text-sm text-gray-500 mt-1" }
    b.use :error, wrap_with: { tag: :p, class: "text-sm text-red-600 mt-1" }
  end

  config.default_wrapper = :default
  config.button_class = "btn btn-primary"
end
```

### Shared Form Template

```erb
<%# app/views/application/_form.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4"
       data-controller="modal"
       data-action="keydown.esc->modal#close click->modal#closeOnBackdrop">
    <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
         data-modal-target="content">

      <%# Header %>
      <div class="flex justify-between items-center p-4 border-b">
        <h2 class="text-xl font-semibold">
          <%= resource.new_record? ? "New" : "Edit" %> <%= resource_name.humanize %>
        </h2>
        <%= link_to "×", collection_path, class: "text-2xl text-gray-500 hover:text-gray-700",
            data: { turbo_frame: "_top" } %>
      </div>

      <%# Form %>
      <%= simple_form_for resource, url: form_url, html: { class: "p-4" } do |f| %>
        <% resource_class.form_fields.each do |field_config| %>
          <%= render_form_field(f, field_config) %>
        <% end %>

        <div class="flex justify-end space-x-3 mt-6 pt-4 border-t">
          <%= link_to "Cancel", collection_path, class: "btn btn-secondary" %>
          <%= f.submit class: "btn btn-primary" %>
        </div>
      <% end %>
    </div>
  </div>
<% end %>
```

### Form Field Helper

```ruby
# app/helpers/form_helper.rb
module FormHelper
  def render_form_field(form, config)
    field = config[:field]
    type = config[:type]

    case type
    when :string
      form.input field, as: :string, required: config[:required]
    when :text
      form.input field, as: :text, input_html: { rows: 4 }
    when :select
      form.input field, as: :select, collection: config[:options],
                 include_blank: true, required: config[:required]
    when :association
      form.association field, collection: instance_exec(&config[:collection]),
                       label_method: :name, value_method: :id
    when :date
      form.input field, as: :date, html5: true
    when :boolean
      form.input field, as: :boolean
    when :array
      form.input field, as: :select, collection: config[:options],
                 input_html: { multiple: true }
    end
  end
end
```

---

## Turbo & Stimulus Patterns

### Key Turbo Frames

```erb
<%# Main content area - reloads on navigation %>
<%= turbo_frame_tag "main_content" %>

<%# Resource lists - update independently %>
<%= turbo_frame_tag "plants_list" %>
<%= turbo_frame_tag "observations_list" %>

<%# Modal for new/edit forms %>
<%= turbo_frame_tag "modal" %>

<%# Sidebar that can be updated %>
<%= turbo_frame_tag "sidebar" %>
```

### Turbo Stream Responses

```erb
<%# app/views/plants/create.turbo_stream.erb %>
<%= turbo_stream.prepend "plants_list" do %>
  <%= render "application/row", item: @resource, columns: Plant.list_columns %>
<% end %>

<%= turbo_stream.replace "modal" do %>
  <%# Empty - closes modal %>
<% end %>

<%= turbo_stream.prepend "flash" do %>
  <%= render "application/toast", message: "Plant created successfully" %>
<% end %>
```

### Essential Stimulus Controllers

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  close() {
    this.element.remove()
  }

  closeOnBackdrop(event) {
    if (!this.contentTarget.contains(event.target)) {
      this.close()
    }
  }
}
```

```javascript
// app/javascript/controllers/filters_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
```

```javascript
// app/javascript/controllers/live_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(async () => {
      const response = await fetch(`${this.urlValue}?q=${this.inputTarget.value}`)
      this.resultsTarget.innerHTML = await response.text()
    }, 200)
  }
}
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
**Goal**: Core infrastructure working

```
1. [ ] Add gems (simple_form, pagy, datagrid, pundit)
2. [ ] Configure Tailwind with component classes
3. [ ] Create CrudController concern
4. [ ] Create Viewable model concern
5. [ ] Build main layout with navbar
6. [ ] Create shared partials (index, form, pagination)
7. [ ] Setup Stimulus controllers (modal, filters, mobile-menu)
8. [ ] Create DashboardController
```

### Phase 2: Core Resources (Week 2)
**Goal**: Main workflow functional

```
1. [ ] TeamsController + views
2. [ ] MembershipsController + views
3. [ ] ProjectsController + views + grid
4. [ ] PlantsController + views + grid
5. [ ] StrainsController + views + grid
```

### Phase 3: Observations & Selections (Week 3)
**Goal**: Data collection working

```
1. [ ] ObservationsController + views
2. [ ] SelectionsController + views
3. [ ] PhotosController + uploads
4. [ ] Plant detail page (combines all)
```

### Phase 4: Settings & Polish (Week 4)
**Goal**: Complete MVP

```
1. [ ] Settings::TraitCategoriesController
2. [ ] Settings::TraitDefinitionsController
3. [ ] Settings::TagsController
4. [ ] Settings::OrganizationsController
5. [ ] Pundit policies for all resources
6. [ ] Mobile navigation refinement
7. [ ] Empty states and loading states
8. [ ] Error handling and validation messages
```

---

## File Structure

### Final Directory Structure

```
app/
├── controllers/
│   ├── concerns/
│   │   ├── crud_controller.rb
│   │   └── authentication.rb
│   ├── application_controller.rb
│   ├── dashboard_controller.rb
│   ├── teams_controller.rb
│   ├── memberships_controller.rb
│   ├── projects_controller.rb
│   ├── plants_controller.rb
│   ├── strains_controller.rb
│   ├── observations_controller.rb
│   ├── selections_controller.rb
│   ├── photos_controller.rb
│   ├── lab_tests_controller.rb
│   └── settings/
│       ├── trait_categories_controller.rb
│       ├── trait_definitions_controller.rb
│       ├── tags_controller.rb
│       └── organizations_controller.rb
│
├── grids/
│   ├── plants_grid.rb
│   ├── projects_grid.rb
│   ├── strains_grid.rb
│   └── observations_grid.rb
│
├── helpers/
│   ├── application_helper.rb
│   ├── form_helper.rb
│   ├── navigation_helper.rb
│   └── badge_helper.rb
│
├── javascript/controllers/
│   ├── modal_controller.js
│   ├── filters_controller.js
│   ├── live_search_controller.js
│   ├── mobile_menu_controller.js
│   ├── dropdown_controller.js
│   └── flash_controller.js
│
├── models/concerns/
│   └── viewable.rb
│
├── policies/
│   ├── application_policy.rb
│   ├── team_policy.rb
│   ├── project_policy.rb
│   ├── plant_policy.rb
│   └── strain_policy.rb
│
└── views/
    ├── application/
    │   ├── _index.html.erb
    │   ├── _form.html.erb
    │   ├── _row.html.erb
    │   ├── _card.html.erb
    │   ├── _filters.html.erb
    │   ├── _pagination.html.erb
    │   ├── _empty_state.html.erb
    │   ├── _flash.html.erb
    │   ├── _toast.html.erb
    │   └── _modal.html.erb
    ├── layouts/
    │   ├── application.html.erb
    │   ├── _head.html.erb
    │   ├── _navbar.html.erb
    │   ├── _sidebar.html.erb
    │   └── _user_menu.html.erb
    ├── dashboard/
    │   └── index.html.erb
    ├── teams/
    │   └── (overrides only)
    ├── plants/
    │   ├── _plant_card.html.erb (custom)
    │   └── show.html.erb (detail page)
    └── ...
```

---

## CSS Component Classes

### Tailwind CSS Button Classes

```css
/* app/assets/stylesheets/components.css */
@layer components {
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2;
  }
  .btn-primary {
    @apply bg-green-600 text-white hover:bg-green-700 focus:ring-green-500;
  }
  .btn-secondary {
    @apply bg-gray-200 text-gray-800 hover:bg-gray-300 focus:ring-gray-500;
  }
  .btn-danger {
    @apply bg-red-600 text-white hover:bg-red-700 focus:ring-red-500;
  }

  .input {
    @apply rounded-lg border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500;
  }
  .input-error {
    @apply border-red-500 focus:border-red-500 focus:ring-red-500;
  }

  .badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
  }
  .badge-green { @apply bg-green-100 text-green-800; }
  .badge-yellow { @apply bg-yellow-100 text-yellow-800; }
  .badge-red { @apply bg-red-100 text-red-800; }
  .badge-blue { @apply bg-blue-100 text-blue-800; }
  .badge-gray { @apply bg-gray-100 text-gray-800; }
}
```

---

## Summary

This plan provides:

1. **90% Code Reuse**: CrudController + shared views handle most cases
2. **Minimal Controllers**: ~20 lines per controller on average
3. **Zero Duplicate Views**: Data-driven templates for all resources
4. **Mobile-First**: Responsive from the start
5. **Turbo Native**: Frames and streams baked in
6. **Easy Override**: Special cases can override defaults easily

**Next Steps**: Start with Phase 1 foundation work 

