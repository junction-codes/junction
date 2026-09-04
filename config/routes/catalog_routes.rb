# frozen_string_literal: true

module Junction
  # Draws the routes for catalog entities that use "friendly" routes with
  # namespace and name segments (e.g. /apis/:namespace/:name).
  module CatalogRoutes
    # Routes belonging to a single kind, keyed by scope. Everything else is
    # drawn the same way for every sluggable kind, so only the exceptions are
    # listed here.
    #
    # Procs rather than lambdas: the router evaluates them with `instance_eval`,
    # which passes the receiver and would trip a lambda's arity check.
    EXTRA_ROUTES = {
      domain: proc { get "systems", to: "domains#systems", as: :domain_systems },
      group: proc { sluggable_group_member_routes },
      system: proc {
        get "apis", to: "systems#apis", as: :system_apis
        get "components", to: "systems#components", as: :system_components
        get "resources", to: "systems#resources", as: :system_resources
      }
    }.freeze

    # Draws the catalog routes into the provided router.
    #
    # @param router [ActionDispatch::Routing::Mapper] The router to draw routes
    #   into.
    def self.draw(router)
      router.extend(RouteBuilder)
      router.draw_catalog!
    end

    # Methods for building catalog routes, to be mixed into the route mapper.
    module RouteBuilder
      # Draws the catalog routes into the router.
      # Every kind the registry exposes with namespace/name routes is drawn
      # here, so registering a kind is all it takes to route it.
      def draw_catalog!
        Junction::Kinds.sluggable.each do |kind|
          plural = kind.plural.to_sym

          # The scope default exists so the shared dependency controllers can
          # recover the model from the URL, so only kinds with dependency
          # routes carry one.
          sluggable_catalog(plural, catalog_scope: (kind.scope.to_s if kind.dependable?)) do
            sluggable_member_dependencies(plural) if kind.dependable?
            instance_eval(&EXTRA_ROUTES[kind.scope]) if EXTRA_ROUTES.key?(kind.scope)
          end
        end
      end

      private

      # Draws the routes for an individual catalog entity type.
      #
      # @param plural [Symbol] Plural form of the entity type to identify the
      #   controller.
      # @param catalog_scope [String] Scope identifier for entity types that
      #   may have nested routes.
      # @param extra [Proc] Additional routes to nest inside the member scope.
      def sluggable_catalog(plural, catalog_scope: nil, &extra)
        resources plural, only: %i[index new create], controller: plural.to_s

        scope_opts = { constraints: Junction::CatalogRouteConstraints::SLUG }
        scope_opts[:defaults] = { catalog_scope: } if catalog_scope

        scope "/#{plural}/:namespace/:name", **scope_opts do
          sluggable_member_crud(plural)
          instance_eval(&extra) if extra
        end
      end

      # Draws the standard CRUD routes for a catalog entity type.
      #
      # @param plural [Symbol] Plural form of the entity type to identify the
      #   controller.
      def sluggable_member_crud(plural)
        singular = plural.to_s.singularize.to_sym

        get "", to: "#{plural}#show", as: singular
        get "edit", to: "#{plural}#edit", as: :"edit_#{singular}"
        match "", via: %i[patch put], to: "#{plural}#update"
        delete "", to: "#{plural}#destroy"
      end

      # Draws the dependencies, dependents, and group routes for a member.
      #
      # @param plural [Symbol] Plural form of the entity type to identify the
      #   controller.
      def sluggable_member_dependencies(plural)
        singular = plural.to_s.singularize

        get "dependency_graph", to: "#{plural}#dependency_graph", as: :"#{singular}_dependency_graph"
        get "dependencies/search", to: "dependencies#search", as: :"search_#{singular}_dependencies"
        resources :dependencies, only: %i[index create], controller: "dependencies", as: :"#{singular}_dependencies"
        resources :dependents, only: :index, controller: "dependents", as: :"#{singular}_dependents"
      end

      # Draws the group member routes for a member.
      #
      # @param plural [Symbol] Plural form of the entity type to identify the
      #   controller.
      def sluggable_group_member_routes
        get "members/search", to: "group_members#search", as: :search_group_members
        get "members", to: "group_members#index", as: :group_members
        post "members", to: "group_members#create"
        delete "members/:id", to: "group_members#destroy", as: :group_member
      end
    end
  end
end
