# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA support
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dashboard (root)
  root "dashboard#index"

  # Organization-scoped resources
  resources :teams do
    resources :projects do
      resources :plants do
        resources :observations, shallow: true
        resources :photos, shallow: true
        resources :lab_tests, shallow: true
        resources :selections, shallow: true
        member do
          post :transition_stage
        end
      end
      resources :project_goals, shallow: true
    end
    resources :memberships, only: [:index, :create, :update, :destroy]
  end

  # Strain library
  resources :strains do
    resources :photos, shallow: true
  end

  # Settings & Admin
  namespace :settings do
    resources :trait_categories do
      resources :trait_definitions, shallow: true
    end
    resources :tags
    resource :organization, only: [:show, :edit, :update]
  end

  # API namespace (for mobile app)
  namespace :api do
    namespace :v1 do
      resources :projects, only: [:index, :show]
      resources :plants, only: [:index, :show, :update] do
        resources :observations, only: [:index, :create]
        resources :photos, only: [:index, :create]
      end
      resources :strains, only: [:index, :show]
    end
  end
end
