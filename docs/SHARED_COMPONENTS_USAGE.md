# Shared Components Usage Guide

This document provides examples of how to use the shared partials and helpers in Phenow.

## Shared Partials

### Pagination

Located at: `app/views/shared/_pagination.html.erb`

**Usage in controller:**
```ruby
def index
  @pagy, @plants = pagy(Plant.all)
end
```

**Usage in view:**
```erb
<%= render "shared/pagination", pagy: @pagy %>
```

---

### Empty State

Located at: `app/views/shared/_empty_state.html.erb`

**Usage:**
```erb
<%= render "shared/empty_state",
           title: "No plants yet",
           description: "Start your phenohunt by adding your first plant.",
           action_path: new_project_plant_path(@project),
           action_text: "Add Plant" %>
```

**Without action button:**
```erb
<%= render "shared/empty_state",
           title: "No results found",
           description: "Try adjusting your search criteria." %>
```

---

### Modal

Located at: `app/views/shared/_modal.html.erb`

**Usage:**
```erb
<%= render "shared/modal", title: "Add New Observation" do %>
  <%= form_with model: [@plant, @observation] do |f| %>
    <!-- form fields -->
  <% end %>
<% end %>
```

**Notes:**
- Uses `turbo_frame_tag "modal"` for Turbo Frame integration
- Includes Stimulus controller for close behavior
- Click outside modal to close
- ESC key support can be added via Stimulus controller

---

### Search Field

Located at: `app/views/shared/_search_field.html.erb`

**Usage:**
```erb
<%= render "shared/search_field",
           name: "q",
           placeholder: "Search plants...",
           value: params[:q] %>
```

**Minimal usage (uses defaults):**
```erb
<%= render "shared/search_field" %>
```

**Features:**
- Auto-submits with 300ms debounce
- Uses Turbo Frame for live updates
- Requires `data: { turbo_frame: "content" }` wrapper in view

---

## Helper Methods

### FormHelper

Located at: `app/helpers/form_helper.rb`

#### `form_input_class(record, field)`

Returns appropriate CSS class for form inputs, adding error class if validation fails.

**Usage:**
```erb
<%= f.text_field :name, class: form_input_class(@plant, :name) %>
```

#### `error_for(record, field)`

Displays validation error message for a field.

**Usage:**
```erb
<%= f.text_field :name, class: form_input_class(@plant, :name) %>
<%= error_for(@plant, :name) %>
```

---

### TableHelper

Located at: `app/helpers/table_helper.rb`

#### `sort_link(column, label)`

Generates sortable column headers with arrow indicators.

**Usage in view:**
```erb
<thead>
  <tr>
    <th><%= sort_link :plant_id, "Plant ID" %></th>
    <th><%= sort_link :observed_at, "Date" %></th>
    <th><%= sort_link :growth_stage, "Stage" %></th>
  </tr>
</thead>
```

**Usage in controller:**
```ruby
def index
  @plants = Plant.all
  @plants = @plants.order("#{params[:sort]} #{params[:direction]}") if params[:sort]
  @pagy, @plants = pagy(@plants)
end
```

---

### BadgeHelper

Located at: `app/helpers/badge_helper.rb`

#### `status_badge(status)`

Renders plant status badge with appropriate styling.

**Usage:**
```erb
<%= status_badge(@plant.status) %>
```

**Output:**
```html
<span class="badge badge-success">Keeper</span>
```

**Status mappings:**
- `active` → `badge-info`
- `keeper` → `badge-success`
- `culled` → `badge-danger`
- `harvested` → `badge-warning`
- `archived` → `badge-secondary`

#### `stage_badge(stage)`

Renders growth stage badge.

**Usage:**
```erb
<%= stage_badge(@plant.growth_stage) %>
```

**Output:**
```html
<span class="badge badge-stage">Pre Flower</span>
```

---

### ApplicationHelper

Located at: `app/helpers/application_helper.rb`

Includes `Pagy::Frontend` module to enable Pagy pagination helpers throughout the application.

**Available methods:**
- `pagy_nav(pagy)` - Renders navigation links
- `pagy_info(pagy)` - Renders info text ("Displaying items 1-20 of 100")
- `pagy_nav_js(pagy)` - JavaScript-based navigation

---

## CSS Classes Reference

These semantic CSS classes are used by the components and should be defined in your stylesheet:

### Form Classes
- `.form-input` - Standard input field
- `.form-input-error` - Input field with validation error
- `.form-error` - Error message text

### Badge Classes
- `.badge` - Base badge class
- `.badge-success` - Green badge (keeper)
- `.badge-danger` - Red badge (culled)
- `.badge-warning` - Yellow badge (harvested)
- `.badge-info` - Blue badge (active)
- `.badge-secondary` - Gray badge (archived)
- `.badge-stage` - Growth stage badge
- `.badge-default` - Default badge style

### Table Classes
- `.table-sort` - Sortable column header
- `.table-sort-active` - Active sort column

### Modal Classes
- `.modal-backdrop` - Dark overlay background
- `.modal` - Modal container
- `.modal-header` - Modal header section
- `.modal-title` - Modal title text
- `.modal-close` - Close button
- `.modal-body` - Modal content area

### Empty State Classes
- `.empty-state` - Container for empty state
- `.empty-state-title` - Title text
- `.empty-state-description` - Description text

### Pagination Classes
- `.pagination` - Pagination container

### Button Classes
- `.btn` - Base button class
- `.btn-primary` - Primary action button

---

## Stimulus Controllers

### ModalController

Located at: `app/javascript/controllers/modal_controller.js`

**Actions:**
- `close` - Closes the modal
- `stopPropagation` - Prevents event bubbling

### FiltersController

Located at: `app/javascript/controllers/filters_controller.js`

**Actions:**
- `submit` - Submits form with 300ms debounce

---

## Example: Complete Index View

```erb
<div class="page-header">
  <h1>Plants</h1>
  <%= link_to "Add Plant", new_project_plant_path(@project), class: "btn btn-primary" %>
</div>

<div class="filters">
  <%= render "shared/search_field", placeholder: "Search plants..." %>
</div>

<%= turbo_frame_tag "content" do %>
  <% if @plants.any? %>
    <table class="table">
      <thead>
        <tr>
          <th><%= sort_link :plant_id, "ID" %></th>
          <th><%= sort_link :name, "Name" %></th>
          <th>Status</th>
          <th>Stage</th>
        </tr>
      </thead>
      <tbody>
        <% @plants.each do |plant| %>
          <tr>
            <td><%= plant.plant_id %></td>
            <td><%= link_to plant.name, project_plant_path(@project, plant) %></td>
            <td><%= status_badge(plant.status) %></td>
            <td><%= stage_badge(plant.growth_stage) %></td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <%= render "shared/pagination", pagy: @pagy %>
  <% else %>
    <%= render "shared/empty_state",
               title: "No plants found",
               description: "Start by adding your first plant to this project.",
               action_path: new_project_plant_path(@project),
               action_text: "Add Plant" %>
  <% end %>
<% end %>
```

---

## Example: Form with Validation Errors

```erb
<%= form_with model: [@project, @plant], local: true do |f| %>
  <div class="form-group">
    <%= f.label :plant_id, "Plant ID" %>
    <%= f.text_field :plant_id, class: form_input_class(@plant, :plant_id) %>
    <%= error_for(@plant, :plant_id) %>
  </div>

  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name, class: form_input_class(@plant, :name) %>
    <%= error_for(@plant, :name) %>
  </div>

  <%= f.submit "Save", class: "btn btn-primary" %>
<% end %>
```
