# frozen_string_literal: true

require_relative "../../app/values/junction/kind"

module Junction
  # Registry of every entity kind known to Junction.
  #
  # This is the single source of truth that replaces the hard-coded kind lists
  # previously duplicated across controllers, path helpers, catalog options,
  # the annotations and options overviews, and the core plugin's permission
  # declarations.
  #
  # Kinds are stored as {Junction::Kind} value objects holding **strings**, and
  # model constants are resolved lazily. That is deliberate: routes are drawn
  # before models can safely autoload, so the registry must be usable without
  # referencing a single model class.
  module Kinds
    # Kinds registered by the engine itself.
    #
    # Contexts derive from these scopes and are persisted in
    # `junction_role_permissions`, so a scope may not be renamed without a data
    # migration. See {Junction::Kind#context}.
    CORE = [
      { scope: :api, catalog: true, ownable: true, dependable: true,
        default_icon: "webhook" },
      { scope: :component, catalog: true, ownable: true, dependable: true,
        default_icon: "server" },
      { scope: :resource, catalog: true, ownable: true, dependable: true,
        default_icon: "rows-4" },
      { scope: :domain, catalog: true, ownable: true, tree: true,
        default_icon: "briefcase" },
      { scope: :system, catalog: true, ownable: true, default_icon: "network" },
      # Not sluggable yet: these kinds gain namespace/name routes when their
      # controllers and views land.
      { scope: :template, catalog: true, ownable: true, sluggable: false,
        default_icon: "file-code" },
      { scope: :location, catalog: true, sluggable: false,
        default_icon: "map-pin" },
      { scope: :group, tree: true, default_icon: "users-round" },
      { scope: :user, default_icon: "user-round" },
      { scope: :role, default_icon: "shield-check" }
    ].freeze

    @mutex = Mutex.new

    class << self
      # Registers a kind, replacing any kind already using the same scope.
      #
      # @param scope [String, Symbol] Singular scope for the kind.
      # @param options [Hash] Options forwarded to {Junction::Kind#initialize}.
      # @return [Junction::Kind] The registered kind.
      def register(scope, **options)
        kind = Kind.new(scope, **options)

        @mutex.synchronize do
          registry[kind.scope] = kind
          @indexes = nil
        end

        kind
      end

      # Every registered kind.
      #
      # @return [Array<Junction::Kind>] The registered kinds.
      def all
        registry.values
      end

      # Looks a kind up by its STI name.
      #
      # @param name [String, Symbol] The kind's name (e.g. `"Api"`).
      # @return [Junction::Kind, nil] The kind, if registered.
      def for(name)
        indexes[:by_name][name.to_s]
      end

      # Looks a kind up by its RBAC permission context.
      #
      # @param context [String, Symbol] The permission context (e.g. `"apis"`).
      # @return [Junction::Kind, nil] The kind, if registered.
      def by_context(context)
        indexes[:by_context][context.to_s]
      end

      # Looks a kind up by its singular scope.
      #
      # @param scope [String, Symbol] The scope (e.g. `:api`).
      # @return [Junction::Kind, nil] The kind, if registered.
      def by_scope(scope)
        registry[scope.to_sym]
      end

      # Resolves a kind name to its model class.
      #
      # Used by {Junction::Entity.sti_class_for} so that kinds outside the
      # Junction namespace resolve. Returns nil rather than raising when the
      # name is unknown, letting STI fall back to its own resolution.
      #
      # @param name [String] The kind's name.
      # @return [Class, nil] The model class, if the kind is registered.
      def model_for(name)
        self.for(name)&.model
      end

      # Names of every registered kind.
      #
      # @return [Array<String>] The kind names.
      def names
        all.map(&:name)
      end

      # Permission contexts of every registered kind.
      #
      # @return [Array<String>] The contexts.
      def contexts
        all.map(&:context)
      end

      # Kinds appearing in catalog listings, search, and the dashboard.
      #
      # @return [Array<Junction::Kind>] The catalog kinds.
      def catalog
        all.select(&:catalog?)
      end

      # Names of the kinds appearing in catalog listings.
      #
      # @return [Array<String>] The catalog kind names.
      def catalog_names
        catalog.map(&:name)
      end

      # Kinds routed at `/:plural/:namespace/:name`.
      #
      # @return [Array<Junction::Kind>] The sluggable kinds.
      def sluggable
        all.select(&:sluggable?)
      end

      # Names of the kinds that may be a relation source or target.
      #
      # @return [Array<String>] The dependable kind names.
      def dependable_names
        all.select(&:dependable?).map(&:name)
      end

      # Whether the kind owning the given permission context has an owner.
      #
      # @param context [String, Symbol] The permission context.
      # @return [Boolean]
      def ownable?(context)
        by_context(context)&.ownable? || false
      end

      # Clears the registry and restores the core registrations.
      #
      # @return [void]
      def reset!
        @mutex.synchronize do
          @registry = nil
          @indexes = nil
        end

        registry
        nil
      end

      private

      # The registry, seeded with the core kinds on first access.
      #
      # @return [Hash{Symbol => Junction::Kind}] The registered kinds by scope.
      def registry
        @registry ||= CORE.each_with_object({}) do |options, kinds|
          kind = Kind.new(options[:scope], **options.except(:scope))
          kinds[kind.scope] = kind
        end
      end

      # Lookup indexes, rebuilt whenever the registry changes.
      #
      # @return [Hash{Symbol => Hash}] Indexes by name and by context.
      def indexes
        @indexes ||= {
          by_name: all.index_by(&:name),
          by_context: all.index_by(&:context)
        }
      end
    end
  end
end
