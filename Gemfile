source "https://rubygems.org"

ruby "3.3.6"

# Rails framework
gem "rails", "~> 8.0"

# Database
gem "pg", "~> 1.5"

# Web server
gem "puma", ">= 6.0"

# Asset pipeline
gem "propshaft"
gem "importmap-rails"
gem "tailwindcss-rails"

# Views
gem "haml-rails"      # HAML templates
gem "simple_form"     # Form DSL
gem "datagrid"        # Filterable tables

# Hotwire
gem "turbo-rails"
gem "stimulus-rails"

# Authentication & Authorization
gem "devise", "~> 4.9"
gem "pundit", "~> 2.3"

# Active Storage image processing
gem "image_processing", "~> 1.2"

# JSON serialization
gem "jbuilder"

# Pagination
gem "pagy", "~> 8.0"

# Slug generation
gem "friendly_id", "~> 5.5"

# Background jobs (Rails 8 default)
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

# Deployment
gem "kamal", require: false
gem "thruster", require: false

# Performance
gem "bootsnap", require: false

# Windows timezone data
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "annotaterb"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "rails-controller-testing"  # For assigns() in controller tests
end
