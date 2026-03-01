# frozen_string_literal: true

Junction::Engine.routes.draw do
  resource :session, controller: "sessions"
  resource :dashboard, only: :show, controller: "dashboards"
  resources :passwords, param: :token, controller: "passwords"
  resources :deployments, controller: "deployments"
  resources :domains, controller: "domains"
  resources :resources, controller: "resources"
  resources :groups, controller: "groups"
  resources :roles, controller: "roles"
  resources :users, controller: "users"

  resources :apis, controller: "apis" do
    get :dependency_graph, on: :member
  end

  resources :components, controller: "components" do
    get :dependency_graph, on: :member
  end

  resources :resources, controller: "resources" do
    get :dependency_graph, on: :member
  end

  resources :systems, controller: "systems" do
    get :dependency_graph, on: :member
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # OmniAuth routes for single sign-on.
  get "/auth/:provider/callback", to: "sessions/omniauth#callback"
  get "/auth/failure", to: "sessions/omniauth#failure"

  # Add plugin routes.
  Junction::PluginRouteBuilder.draw(self)

  # Defines the root path route ("/")
  root "dashboards#show"
end
