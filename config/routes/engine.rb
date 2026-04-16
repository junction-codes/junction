# frozen_string_literal: true

require Junction::Engine.root.join("lib/junction/catalog_route_constraints")
require Junction::Engine.root.join("config/routes/catalog_routes")
require Junction::Engine.root.join("lib/junction/path_helper_overrides")

Junction::Engine.routes.draw do
  resource :session, controller: "sessions"
  resource :dashboard, only: :show, controller: "dashboards"
  resources :passwords, param: :token, controller: "passwords"

  Junction::CatalogRoutes.draw(self)

  resources :dependencies, only: :destroy

  get "robots.txt", to: "robots#show", as: :robots

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # OmniAuth routes for single sign-on.
  get "/auth/:provider/callback", to: "sessions/omniauth#callback"
  get "/auth/failure", to: "sessions/omniauth#failure"

  get :search, to: "search#index"
  get "search/autocomplete", to: "search#autocomplete", as: :search_autocomplete

  # Add plugin routes.
  Junction::PluginRouteBuilder.draw(self)

  # Defines the root path route ("/")
  root "dashboards#show"
end

Junction::PathHelperOverrides.apply!(Junction::Engine.routes)
