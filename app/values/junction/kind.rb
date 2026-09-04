# frozen_string_literal: true

module Junction
  # Value object describing a single entity kind.
  #
  # A kind is the STI discriminator value for {Junction::Entity} together with
  # the metadata: the route scope, the RBAC permission context, the catalog
  # options section, and the capability flags deciding which behaviors apply.
  #
  # Everything derives from the singular `scope`, so a kind cannot drift out of
  # sync with itself. That matters most for {#context}: permission strings such
  # as `junction.codes/apis.all.read` are persisted in
  # `junction_role_permissions`, so a context that stopped matching its scope
  # would silently invalidate every stored role permission using it.
  class Kind
    DEFAULT_ICON = "circle"

    attr_reader :scope, :default_icon

    # Initializes a new kind.
    #
    # @param scope [Symbol] Singular scope everything else derives from.
    # @param model_name [String] Model class name when it's not the kind's name
    #   in the Junction namespace. Used for kinds defined by plugins.
    # @param catalog [Boolean] Whether the kind appears in catalog listings,
    #   global search, and the dashboard.
    # @param ownable [Boolean] Whether the kind has an owner and receives
    #   `owned` permissions.
    # @param sluggable [Boolean] Whether the kind is routed at
    #   `/:plural/:namespace/:name`.
    # @param dependable [Boolean] Whether the kind may be a relation source or
    #   target.
    # @param tree [Boolean] Whether the kind uses `parent_id` for a hierarchy.
    # @param exposed [Boolean] Whether the kind is surfaced to end users at
    #   all. A kind that is registered but not exposed still resolves from the
    #   database, so existing rows load, but it has no permissions, no routes,
    #   and appears in no listing.
    # @param domain [String] Permission domain the kind's permissions belong to.
    #   Defaults to the core domain. Kinds registered by plugins should set this
    #   to the plugin's domain.
    # @param default_icon [String] Icon used when the entity's type declares
    #   none.
    def initialize(scope, model_name: nil, catalog: false, ownable: false,
                   sluggable: true, dependable: false, tree: false,
                   exposed: true, domain: nil, default_icon: DEFAULT_ICON)
      @scope = scope.to_sym
      @model_name = model_name
      @catalog = catalog
      @ownable = ownable
      @sluggable = sluggable
      @dependable = dependable
      @tree = tree
      @exposed = exposed
      @domain = domain
      @default_icon = default_icon
    end

    # Permission domain this kind's permissions belong to.
    #
    # Resolved lazily rather than defaulted in the constructor: the registry
    # loads before the core plugin does.
    #
    # @return [String] The domain.
    def domain
      @domain || Junction::CorePlugin::DOMAIN
    end

    # STI discriminator value stored in `junction_entities.kind`.
    #
    # @return [String] The kind's name.
    def name
      scope.to_s.camelize
    end

    # Plural form of the scope, used for routes and controller names.
    #
    # @return [String] The plural scope.
    def plural
      scope.to_s.pluralize
    end

    # RBAC permission context.
    #
    # @return [String] The permission context.
    def context
      plural
    end

    # Catalog options section holding this kind's type vocabulary.
    #
    # @return [Symbol] The section name.
    def section
      plural.to_sym
    end

    # Name of the model class backing this kind.
    #
    # @return [String] The model class name.
    def model_name
      @model_name || "Junction::#{name}"
    end

    # Model class backing this kind.
    #
    # @return [Class] The model class.
    def model
      model_name.constantize
    end

    # Whether the kind appears in catalog listings, search, and the dashboard.
    #
    # Auth principals and RBAC configuration are deliberately excluded, which
    # is what keeps them out of user-facing catalog queries now that every kind
    # shares a table.
    #
    # @return [Boolean]
    def catalog?
      @catalog
    end

    # Whether the kind has an owner.
    #
    # @return [Boolean]
    def ownable?
      @ownable
    end

    # Whether the kind is routed at `/:plural/:namespace/:name`.
    #
    # @return [Boolean]
    def sluggable?
      @sluggable
    end

    # Whether the kind may be a relation source or target.
    #
    # @return [Boolean]
    def dependable?
      @dependable
    end

    # Whether the kind uses `parent_id` for a hierarchy.
    #
    # @return [Boolean]
    def tree?
      @tree
    end

    # Whether the kind is surfaced to end users.
    #
    # A kind may be registered before it has controllers and views. Until it's
    # exposed it declares no permissions, draws no routes, and appears in no
    # listings, but it still resolves from `kind` so that rows created by seeds
    # or a plugin load as the right class rather than failing.
    #
    # @return [Boolean]
    def exposed?
      @exposed
    end
  end
end
