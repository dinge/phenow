# UI & Controllers Implementation Plan

> Simple, modern Rails 8 approach - minimal gems, semantic CSS, importmaps.

## Table of Contents
1. [Philosophy](#philosophy)
2. [Rails Setup (Modern)](#rails-setup-modern)
3. [Semantic CSS Components](#semantic-css-components)
4. [Controller Abstraction](#controller-abstraction)
5. [View System](#view-system)
6. [Filtering & Search](#filtering--search)
7. [Forms](#forms)
8. [Turbo & Stimulus](#turbo--stimulus)
9. [Implementation Phases](#implementation-phases)

---

## Philosophy

### Keep It Simple
- **HAML over ERB** - cleaner, faster, less noise
- **Simple Form for forms** - DRY form DSL with semantic wrappers
- **Datagrid for lists** - filterable, sortable tables with minimal code
- **Semantic HTML + CSS** - no utility class soup in views
- **Importmaps** - no Node.js, no npm, no bundlers
- **Tailwind standalone** - CSS only, compiled by CLI
- **Reusable partials** - common views for index/form/row patterns

### What We Use
| Need | Solution |
|------|----------|
| Views | **HAML** (haml-rails) - faster, cleaner templates |
| Forms | **simple_form** - semantic form DSL with wrappers |
| Lists | **datagrid** - filterable/sortable tables |
| JS modules | Importmaps (Rails 8 default) |
| CSS | Tailwind standalone CLI via `tailwindcss-rails` |
| Pagination | `pagy` (already in Gemfile) |
| Auth | `devise` + `pundit` (already in Gemfile) |

### Rules (MUST FOLLOW)
1. **All views MUST be HAML** - no ERB files
2. **All forms MUST use simple_form** - `simple_form_for` not `form_with`
3. **All list views MUST use datagrid** - define grid classes in `app/grids/`
4. **Semantic CSS only** - use `.btn-primary` not `class="px-4 py-2 bg-green-600..."`
5. **Reusable partials** - common patterns in `app/views/application/`

---

## Rails Setup (Modern)

### Switch to Importmaps

```ruby
# Gemfile - REMOVE these:
# gem "cssbundling-rails"
# gem "jsbundling-rails"

# ADD these:
gem "importmap-rails"
gem "tailwindcss-rails"  # Standalone CLI, no Node
```

### Setup Commands

```bash
# Remove old bundling
rm -rf node_modules package.json yarn.lock

# Install importmaps
rails importmap:install

# Install Tailwind standalone
rails tailwindcss:install

# Pin Stimulus (if not already)
bin/importmap pin @hotwired/stimulus @hotwired/turbo-rails
```

### Config Files

```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"
```

---

## Semantic CSS Components

### Design Principle

Views use **semantic class names**. All Tailwind utilities are hidden inside CSS components.

```erb
<%# GOOD - semantic %>
<button class="btn-primary">Save</button>
<span class="badge-stage">Flowering</span>
<div class="card">...</div>

<%# BAD - utility soup %>
<button class="px-4 py-2 bg-green-600 text-white rounded-lg...">Save</button>
```

### Component Library

```css
/* app/assets/stylesheets/application.tailwind.css */

@tailwind base;
@tailwind components;
@tailwind utilities;

/* ============================================
   BUTTONS
   ============================================ */
@layer components {
  .btn {
    @apply inline-flex items-center justify-center
           px-4 py-2 rounded-lg font-medium
           transition-colors duration-150
           focus:outline-none focus:ring-2 focus:ring-offset-2
           disabled:opacity-50 disabled:cursor-not-allowed;
  }

  .btn-primary {
    @apply btn bg-green-600 text-white
           hover:bg-green-700 focus:ring-green-500;
  }

  .btn-secondary {
    @apply btn bg-white text-gray-700 border border-gray-300
           hover:bg-gray-50 focus:ring-green-500;
  }

  .btn-danger {
    @apply btn bg-red-600 text-white
           hover:bg-red-700 focus:ring-red-500;
  }

  .btn-ghost {
    @apply btn bg-transparent text-gray-600
           hover:bg-gray-100 focus:ring-gray-500;
  }

  .btn-sm { @apply text-sm px-3 py-1.5; }
  .btn-lg { @apply text-lg px-6 py-3; }
}

/* ============================================
   FORMS
   ============================================ */
@layer components {
  .form-group {
    @apply mb-4;
  }

  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }

  .form-input {
    @apply block w-full rounded-lg border-gray-300 shadow-sm
           focus:border-green-500 focus:ring-green-500
           disabled:bg-gray-100 disabled:cursor-not-allowed;
  }

  .form-input-error {
    @apply form-input border-red-500
           focus:border-red-500 focus:ring-red-500;
  }

  .form-select {
    @apply form-input;
  }

  .form-textarea {
    @apply form-input resize-y;
  }

  .form-checkbox {
    @apply rounded border-gray-300 text-green-600
           focus:ring-green-500;
  }

  .form-hint {
    @apply mt-1 text-sm text-gray-500;
  }

  .form-error {
    @apply mt-1 text-sm text-red-600;
  }
}

/* ============================================
   BADGES (status, stage, etc.)
   ============================================ */
@layer components {
  .badge {
    @apply inline-flex items-center px-2.5 py-0.5
           rounded-full text-xs font-medium;
  }

  /* Status badges */
  .badge-active   { @apply badge bg-green-100 text-green-800; }
  .badge-keeper   { @apply badge bg-emerald-100 text-emerald-800; }
  .badge-culled   { @apply badge bg-red-100 text-red-800; }
  .badge-archived { @apply badge bg-gray-100 text-gray-800; }

  /* Stage badges */
  .badge-stage {
    @apply badge bg-blue-100 text-blue-800;
  }

  /* Generic */
  .badge-info    { @apply badge bg-blue-100 text-blue-800; }
  .badge-success { @apply badge bg-green-100 text-green-800; }
  .badge-warning { @apply badge bg-yellow-100 text-yellow-800; }
  .badge-error   { @apply badge bg-red-100 text-red-800; }
}

/* ============================================
   CARDS
   ============================================ */
@layer components {
  .card {
    @apply bg-white rounded-lg shadow-sm border border-gray-200;
  }

  .card-header {
    @apply px-4 py-3 border-b border-gray-200;
  }

  .card-body {
    @apply p-4;
  }

  .card-footer {
    @apply px-4 py-3 border-t border-gray-200 bg-gray-50;
  }
}

/* ============================================
   TABLES
   ============================================ */
@layer components {
  .data-table {
    @apply min-w-full divide-y divide-gray-200;
  }

  .data-table thead {
    @apply bg-gray-50;
  }

  .data-table th {
    @apply px-4 py-3 text-left text-xs font-medium
           text-gray-500 uppercase tracking-wider;
  }

  .data-table td {
    @apply px-4 py-3 text-sm text-gray-900;
  }

  .data-table tbody tr {
    @apply hover:bg-gray-50 transition-colors;
  }

  .data-table tbody tr:nth-child(even) {
    @apply bg-gray-25;
  }
}

/* ============================================
   NAVIGATION
   ============================================ */
@layer components {
  .navbar {
    @apply bg-green-700 text-white shadow-md;
  }

  .navbar-brand {
    @apply text-xl font-bold;
  }

  .nav-link {
    @apply px-3 py-2 rounded-md text-sm font-medium
           text-green-100 hover:bg-green-600 hover:text-white
           transition-colors;
  }

  .nav-link-active {
    @apply nav-link bg-green-800 text-white;
  }

  .sidebar {
    @apply w-64 bg-white shadow-sm border-r border-gray-200;
  }

  .sidebar-link {
    @apply flex items-center px-4 py-2 text-sm text-gray-700
           hover:bg-gray-100 rounded-md transition-colors;
  }

  .sidebar-link-active {
    @apply sidebar-link bg-green-50 text-green-700;
  }
}

/* ============================================
   MODALS
   ============================================ */
@layer components {
  .modal-backdrop {
    @apply fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50;
  }

  .modal {
    @apply bg-white rounded-lg shadow-xl max-w-2xl w-full
           max-h-[90vh] overflow-hidden;
  }

  .modal-header {
    @apply flex justify-between items-center p-4 border-b border-gray-200;
  }

  .modal-title {
    @apply text-xl font-semibold text-gray-900;
  }

  .modal-body {
    @apply p-4 overflow-y-auto;
  }

  .modal-footer {
    @apply flex justify-end gap-3 p-4 border-t border-gray-200 bg-gray-50;
  }
}

/* ============================================
   LAYOUT
   ============================================ */
@layer components {
  .page-header {
    @apply flex flex-col sm:flex-row sm:items-center sm:justify-between
           gap-4 mb-6;
  }

  .page-title {
    @apply text-2xl font-bold text-gray-900;
  }

  .page-actions {
    @apply flex items-center gap-2;
  }

  .content-section {
    @apply mb-8;
  }

  .empty-state {
    @apply text-center py-12;
  }

  .empty-state-icon {
    @apply mx-auto h-12 w-12 text-gray-400;
  }

  .empty-state-title {
    @apply mt-2 text-sm font-medium text-gray-900;
  }

  .empty-state-description {
    @apply mt-1 text-sm text-gray-500;
  }
}

/* ============================================
   FILTERS
   ============================================ */
@layer components {
  .filter-bar {
    @apply bg-white p-4 rounded-lg shadow-sm border border-gray-200 mb-4;
  }

  .filter-grid {
    @apply grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4;
  }

  .filter-actions {
    @apply flex justify-end gap-2 mt-4 pt-4 border-t border-gray-200;
  }
}

/* ============================================
   FLASH MESSAGES
   ============================================ */
@layer components {
  .flash {
    @apply p-4 rounded-lg mb-4;
  }

  .flash-notice {
    @apply flash bg-green-50 text-green-800 border border-green-200;
  }

  .flash-alert {
    @apply flash bg-red-50 text-red-800 border border-red-200;
  }

  .flash-warning {
    @apply flash bg-yellow-50 text-yellow-800 border border-yellow-200;
  }
}
```

---

## Controller Abstraction

### CrudController Concern

Handles 80% of CRUD logic. Controllers only define what's different.

```ruby
# app/controllers/concerns/crud_controller.rb
# frozen_string_literal: true

module CrudController
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i[show edit update destroy]
    before_action :set_collection, only: :index
    helper_method :resource, :collection, :resource_class, :resource_name
  end

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

  def edit; end

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

  # Override these in subclasses
  def resource_class     = controller_name.classify.constantize
  def resource_name      = resource_class.model_name.singular
  def collection_name    = resource_class.model_name.plural
  def resource           = @resource
  def collection         = @collection
  def resource_scope     = resource_class.all
  def after_save_path    = url_for(action: :index)
  def after_destroy_path = url_for(action: :index)

  def set_resource
    @resource = find_resource
    authorize @resource if respond_to?(:authorize, true)
  end

  def find_resource
    resource_scope.friendly.find(params[:id])
  rescue NoMethodError
    resource_scope.find(params[:id])
  end

  def build_resource(attrs = {})
    resource_scope.new(attrs)
  end

  def set_collection
    scope = resource_scope
    scope = apply_filters(scope)
    scope = apply_search(scope)
    scope = apply_sorting(scope)
    @pagy, @collection = pagy(scope)
  end

  def apply_filters(scope)
    scope  # Override in subclass
  end

  def apply_search(scope)
    return scope unless params[:q].present?
    scope.search(params[:q])  # Requires .search scope on model
  end

  def apply_sorting(scope)
    return scope unless params[:sort].present?
    direction = params[:dir] == "desc" ? :desc : :asc
    scope.order(params[:sort] => direction)
  end

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
```

### Example Controller

```ruby
# app/controllers/strains_controller.rb
# frozen_string_literal: true

class StrainsController < ApplicationController
  include CrudController

  private

  def resource_scope
    current_organization.strains
  end

  def permitted_attributes
    %i[name breeder strain_type description genetics_type
       flowering_time_min flowering_time_max thc_min thc_max]
  end

  def apply_filters(scope)
    scope = scope.where(strain_type: params[:strain_type]) if params[:strain_type].present?
    scope = scope.where(genetics_type: params[:genetics_type]) if params[:genetics_type].present?
    scope
  end
end
```

### Nested Resource Controller

```ruby
# app/controllers/plants_controller.rb
# frozen_string_literal: true

class PlantsController < ApplicationController
  include CrudController

  before_action :set_project

  private

  def set_project
    @project = current_team.projects.friendly.find(params[:project_id])
  end

  def resource_scope
    @project.plants.includes(:strain)
  end

  def permitted_attributes
    %i[identifier name strain_id source_type sex
       current_stage status germination_date flip_date harvest_date notes]
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
end
```

---

## View System

### Directory Structure

```
app/views/
├── layouts/
│   ├── application.html.erb
│   ├── _navbar.html.erb
│   ├── _sidebar.html.erb
│   ├── _flash.html.erb
│   └── _user_menu.html.erb
│
├── shared/
│   ├── _pagination.html.erb
│   ├── _empty_state.html.erb
│   ├── _modal.html.erb
│   └── _search_field.html.erb
│
├── strains/
│   ├── index.html.erb
│   ├── new.html.erb
│   ├── edit.html.erb
│   ├── _form.html.erb
│   ├── _row.html.erb
│   └── _filters.html.erb
│
└── plants/
    ├── index.html.erb
    ├── ...
```

### Layout

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html class="h-full bg-gray-100">
<head>
  <title><%= content_for(:title) || "Phenow" %></title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>

<body class="h-full">
  <div class="min-h-full">
    <%= render "layouts/navbar" %>

    <div class="flex">
      <%= render "layouts/sidebar" if show_sidebar? %>

      <main class="flex-1 p-4 lg:p-8">
        <%= render "layouts/flash" %>
        <%= yield %>
      </main>
    </div>
  </div>

  <%= turbo_frame_tag "modal" %>
</body>
</html>
```

### Index View Example

```erb
<%# app/views/strains/index.html.erb %>
<div class="page-header">
  <h1 class="page-title">Strains</h1>
  <div class="page-actions">
    <%= link_to "New Strain", new_strain_path, class: "btn-primary",
        data: { turbo_frame: "modal" } %>
  </div>
</div>

<%# Filters %>
<%= render "filters" %>

<%# Table %>
<div class="card">
  <% if collection.any? %>
    <div class="overflow-x-auto">
      <table class="data-table">
        <thead>
          <tr>
            <th><%= sort_link :name, "Name" %></th>
            <th><%= sort_link :breeder, "Breeder" %></th>
            <th>Type</th>
            <th>Genetics</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <% collection.each do |strain| %>
            <%= render "row", strain: strain %>
          <% end %>
        </tbody>
      </table>
    </div>
    <%= render "shared/pagination", pagy: @pagy %>
  <% else %>
    <%= render "shared/empty_state",
        title: "No strains yet",
        description: "Get started by adding your first strain.",
        action_path: new_strain_path,
        action_text: "Add Strain" %>
  <% end %>
</div>
```

### Row Partial

```erb
<%# app/views/strains/_row.html.erb %>
<tr id="<%= dom_id(strain) %>">
  <td>
    <%= link_to strain.name, edit_strain_path(strain),
        class: "text-green-600 hover:text-green-800 font-medium" %>
  </td>
  <td><%= strain.breeder %></td>
  <td><span class="badge-info"><%= strain.strain_type&.humanize %></span></td>
  <td><%= strain.genetics_type&.humanize %></td>
  <td class="text-right">
    <%= link_to "Edit", edit_strain_path(strain), class: "btn-ghost btn-sm" %>
    <%= button_to "Delete", strain_path(strain), method: :delete,
        class: "btn-ghost btn-sm text-red-600",
        form: { data: { turbo_confirm: "Delete this strain?" } } %>
  </td>
</tr>
```

---

## Filtering & Search

### Simple Filter Implementation

No gem needed - just scopes and params.

```ruby
# app/models/strain.rb
class Strain < ApplicationRecord
  # Search scope
  scope :search, ->(q) {
    where("name ILIKE :q OR breeder ILIKE :q", q: "%#{q}%")
  }

  # Filter scopes
  scope :by_type, ->(type) { where(strain_type: type) }
  scope :by_genetics, ->(gen) { where(genetics_type: gen) }
end
```

### Filter Partial

```erb
<%# app/views/strains/_filters.html.erb %>
<%= form_with url: strains_path, method: :get, class: "filter-bar",
    data: { controller: "filters", turbo_frame: "_top" } do |f| %>
  <div class="filter-grid">
    <div class="form-group">
      <%= f.label :q, "Search", class: "form-label" %>
      <%= f.text_field :q, value: params[:q], class: "form-input",
          placeholder: "Name or breeder...",
          data: { action: "input->filters#submit" } %>
    </div>

    <div class="form-group">
      <%= f.label :strain_type, "Type", class: "form-label" %>
      <%= f.select :strain_type, Strain::TYPES.map { |t| [t.humanize, t] },
          { include_blank: "All types" },
          class: "form-select",
          data: { action: "change->filters#submit" } %>
    </div>

    <div class="form-group">
      <%= f.label :genetics_type, "Genetics", class: "form-label" %>
      <%= f.select :genetics_type, Strain::GENETICS_TYPES.map { |t| [t.humanize, t] },
          { include_blank: "All genetics" },
          class: "form-select",
          data: { action: "change->filters#submit" } %>
    </div>
  </div>

  <div class="filter-actions">
    <%= link_to "Clear", strains_path, class: "btn-secondary" %>
  </div>
<% end %>
```

### Sort Helper

```ruby
# app/helpers/table_helper.rb
module TableHelper
  def sort_link(column, label)
    direction = (params[:sort] == column.to_s && params[:dir] != "desc") ? "desc" : "asc"
    arrow = if params[:sort] == column.to_s
              params[:dir] == "desc" ? " ↓" : " ↑"
            else
              ""
            end

    link_to "#{label}#{arrow}".html_safe,
            url_for(sort: column, dir: direction, **request.query_parameters.except(:sort, :dir)),
            class: "hover:text-gray-700"
  end
end
```

---

## Forms

### Using Rails Form Helpers (No simple_form)

```erb
<%# app/views/strains/_form.html.erb %>
<%= form_with model: strain, class: "space-y-4" do |f| %>
  <% if strain.errors.any? %>
    <div class="flash-alert">
      <h3 class="font-medium">Please fix the following errors:</h3>
      <ul class="mt-2 list-disc list-inside">
        <% strain.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= f.label :name, class: "form-label" %>
    <%= f.text_field :name, class: form_input_class(strain, :name), required: true %>
    <%= error_for strain, :name %>
  </div>

  <div class="form-group">
    <%= f.label :breeder, class: "form-label" %>
    <%= f.text_field :breeder, class: form_input_class(strain, :breeder) %>
  </div>

  <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
    <div class="form-group">
      <%= f.label :strain_type, class: "form-label" %>
      <%= f.select :strain_type, Strain::TYPES.map { |t| [t.humanize, t] },
          { include_blank: "Select type..." },
          class: form_input_class(strain, :strain_type) %>
    </div>

    <div class="form-group">
      <%= f.label :genetics_type, class: "form-label" %>
      <%= f.select :genetics_type, Strain::GENETICS_TYPES.map { |t| [t.humanize, t] },
          { include_blank: "Select genetics..." },
          class: form_input_class(strain, :genetics_type) %>
    </div>
  </div>

  <div class="form-group">
    <%= f.label :description, class: "form-label" %>
    <%= f.text_area :description, rows: 4, class: form_input_class(strain, :description) %>
  </div>

  <div class="flex justify-end gap-3 pt-4 border-t border-gray-200">
    <%= link_to "Cancel", strains_path, class: "btn-secondary" %>
    <%= f.submit class: "btn-primary" %>
  </div>
<% end %>
```

### Form Helpers

```ruby
# app/helpers/form_helper.rb
module FormHelper
  def form_input_class(record, field)
    base = "form-input"
    record.errors[field].any? ? "#{base} form-input-error" : base
  end

  def error_for(record, field)
    return unless record.errors[field].any?
    tag.p record.errors[field].first, class: "form-error"
  end
end
```

### Modal Form

```erb
<%# app/views/strains/new.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal-backdrop" data-controller="modal"
       data-action="keydown.esc->modal#close click->modal#closeOnBackdrop">
    <div class="modal" data-modal-target="content">
      <div class="modal-header">
        <h2 class="modal-title">New Strain</h2>
        <%= link_to "×", strains_path, class: "text-2xl text-gray-400 hover:text-gray-600" %>
      </div>

      <div class="modal-body">
        <%= render "form", strain: @resource %>
      </div>
    </div>
  </div>
<% end %>
```

---

## Turbo & Stimulus

### Stimulus Controllers

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  close() {
    this.element.remove()
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
```

```javascript
// app/javascript/controllers/filters_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
```

```javascript
// app/javascript/controllers/mobile_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}
```

```javascript
// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => this.dismiss(), 5000)
  }

  dismiss() {
    this.element.remove()
  }
}
```

### Turbo Patterns

```erb
<%# Auto-submit filter form %>
<%= form_with ..., data: { turbo_frame: "_top" } %>

<%# Open in modal %>
<%= link_to "New", new_path, data: { turbo_frame: "modal" } %>

<%# Confirm before delete %>
<%= button_to "Delete", path, method: :delete,
    form: { data: { turbo_confirm: "Are you sure?" } } %>
```

---

## Implementation Phases

### Phase 1: Foundation
1. Switch to importmaps + tailwindcss-rails
2. Create semantic CSS component library
3. Build CrudController concern
4. Create layout with navbar/sidebar
5. Add shared partials (pagination, flash, empty state)
6. Setup Stimulus controllers

### Phase 2: Core Resources
1. StrainsController + views
2. TeamsController + views
3. ProjectsController + views
4. PlantsController + views

### Phase 3: Data Collection
1. ObservationsController + views
2. SelectionsController + views
3. PhotosController + uploads
4. Plant detail page

### Phase 4: Settings & Polish
1. Settings controllers (TraitCategories, TraitDefinitions, Tags)
2. Pundit policies
3. Mobile refinement
4. Empty states & loading states

---

## Summary

| Aspect | Approach |
|--------|----------|
| **JS** | Importmaps - no Node.js |
| **CSS** | Tailwind standalone + semantic components |
| **Forms** | Rails form helpers |
| **Tables** | Simple partials + scopes |
| **Filters** | Query params + model scopes |
| **Modals** | Turbo Frames |
| **Controllers** | CrudController concern |

**Result**: Clean views with semantic classes, minimal dependencies, pure Rails 8 setup.
