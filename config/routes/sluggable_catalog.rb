# frozen_string_literal: true

# Draws friendly `/…/:namespace/:name` member routes and legacy numeric-id redirects
# for Sluggable catalog resources. Loaded from {Junction::Engine}'s route file.
module Junction
  module SluggableCatalogRoutes
    C = Junction::SluggableRouteConstraints::SLUG
    ID = Junction::SluggableRouteConstraints::NUMERIC_ID

    def self.draw(mapper)
      mapper.instance_exec do
        # --- Apis -----------------------------------------------------------------
        resources :apis, only: %i[index new create], controller: "apis"
        scope "/apis/:namespace/:name", constraints: C, defaults: { catalog_scope: "api" } do
          get "", to: "apis#show", as: :api
          get "edit", to: "apis#edit", as: :edit_api
          match "", via: %i[patch put], to: "apis#update"
          delete "", to: "apis#destroy"
          get "dependency_graph", to: "apis#dependency_graph", as: :api_dependency_graph
          get "dependencies/search", to: "dependencies#search", as: :search_api_dependencies
          resources :dependencies, only: %i[index create], controller: "dependencies", as: :api_dependencies
          resources :dependents, only: :index, controller: "dependents", as: :api_dependents
        end
        match "/apis/:id(/*legacy_sluggable_suffix)", via: :all, to: "apis#redirect_sluggable_from_numeric_id",
              constraints: { id: ID }, as: nil

        # --- Components ---------------------------------------------------------
        resources :components, only: %i[index new create], controller: "components"
        scope "/components/:namespace/:name", constraints: C, defaults: { catalog_scope: "component" } do
          get "", to: "components#show", as: :component
          get "edit", to: "components#edit", as: :edit_component
          match "", via: %i[patch put], to: "components#update"
          delete "", to: "components#destroy"
          get "dependency_graph", to: "components#dependency_graph", as: :component_dependency_graph
          get "dependencies/search", to: "dependencies#search", as: :search_component_dependencies
          resources :dependencies, only: %i[index create], controller: "dependencies", as: :component_dependencies
          resources :dependents, only: :index, controller: "dependents", as: :component_dependents
        end
        match "/components/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "components#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Domains -------------------------------------------------------------
        resources :domains, only: %i[index new create], controller: "domains"
        scope "/domains/:namespace/:name", constraints: C do
          get "", to: "domains#show", as: :domain
          get "edit", to: "domains#edit", as: :edit_domain
          match "", via: %i[patch put], to: "domains#update"
          delete "", to: "domains#destroy"
          get "systems", to: "domains#systems", as: :domain_systems
        end
        match "/domains/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "domains#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Groups --------------------------------------------------------------
        resources :groups, only: %i[index new create], controller: "groups"
        scope "/groups/:namespace/:name", constraints: C do
          get "", to: "groups#show", as: :group
          get "edit", to: "groups#edit", as: :edit_group
          match "", via: %i[patch put], to: "groups#update"
          delete "", to: "groups#destroy"
          get "members/search", to: "group_members#search", as: :search_group_members
          get "members", to: "group_members#index", as: :group_members
          post "members", to: "group_members#create"
          delete "members/:id", to: "group_members#destroy", as: :group_member
        end
        match "/groups/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "groups#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Resources (single resources block) ---------------------------------
        resources :resources, only: %i[index new create], controller: "resources"
        scope "/resources/:namespace/:name", constraints: C, defaults: { catalog_scope: "resource" } do
          get "", to: "resources#show", as: :resource
          get "edit", to: "resources#edit", as: :edit_resource
          match "", via: %i[patch put], to: "resources#update"
          delete "", to: "resources#destroy"
          get "dependency_graph", to: "resources#dependency_graph", as: :resource_dependency_graph
          get "dependencies/search", to: "dependencies#search", as: :search_resource_dependencies
          resources :dependencies, only: %i[index create], controller: "dependencies", as: :resource_dependencies
          resources :dependents, only: :index, controller: "dependents", as: :resource_dependents
        end
        match "/resources/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "resources#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Roles ---------------------------------------------------------------
        resources :roles, only: %i[index new create], controller: "roles"
        scope "/roles/:namespace/:name", constraints: C do
          get "", to: "roles#show", as: :role
          get "edit", to: "roles#edit", as: :edit_role
          match "", via: %i[patch put], to: "roles#update"
          delete "", to: "roles#destroy"
        end
        match "/roles/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "roles#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Systems -------------------------------------------------------------
        resources :systems, only: %i[index new create], controller: "systems"
        scope "/systems/:namespace/:name", constraints: C do
          get "", to: "systems#show", as: :system
          get "edit", to: "systems#edit", as: :edit_system
          match "", via: %i[patch put], to: "systems#update"
          delete "", to: "systems#destroy"
          get "apis", to: "systems#apis", as: :system_apis
          get "components", to: "systems#components", as: :system_components
          get "resources", to: "systems#resources", as: :system_resources
        end
        match "/systems/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "systems#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil

        # --- Users ---------------------------------------------------------------
        resources :users, only: %i[index new create], controller: "users"
        scope "/users/:namespace/:name", constraints: C do
          get "", to: "users#show", as: :user
          get "edit", to: "users#edit", as: :edit_user
          match "", via: %i[patch put], to: "users#update"
          delete "", to: "users#destroy"
        end
        match "/users/:id(/*legacy_sluggable_suffix)", via: :all,
              to: "users#redirect_sluggable_from_numeric_id", constraints: { id: ID }, as: nil
      end
    end
  end
end
