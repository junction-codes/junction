# frozen_string_literal: true

module Junction
  # Extends the engine's generated route helpers so "single model" call sites work.
  #
  # == The problem
  #
  # Sluggable catalog URLs look like +/apis/:namespace/:name+ (and similar for other
  # resources). Rails generates helpers such as +api_path(namespace:, name:)+ — it does
  # not accept +api_path(api)+ with one +Api+ record. Callers would otherwise have to
  # repeat +namespace: record.namespace, name: record.name+ everywhere.
  #
  # == What we do
  #
  # For each listed +[helper_method, model_class]+ in +PAIRS+, we +prepend+ a thin module
  # in front of the engine's path helper module (and the URL helper module) that
  # intercepts calls like +component_path(component)+ and forwards to
  # +super(namespace: ..., name: ...)+. Any other call shape (+super+ with explicit
  # keywords or legacy positional args) is passed through unchanged.
  #
  # == Why prepend path *and* URL modules with *two* different Module instances
  #
  # URL helpers (+api_url+) are defined on a separate module from path helpers (+api_path+).
  # In Ruby, the same +Module+ can only be prepended to one ancestor chain; prepending it
  # to a second module detaches it from the first and breaks +super+. So +build_mixin+
  # creates a fresh anonymous module per kind (+path+ vs +:url+) per route set.
  #
  # == Where this is wired up
  #
  # See +config/routes/engine.rb+ — +Junction::SluggablePathHelperOverrides.apply!+
  # runs after +Junction::Engine.routes.draw+.
  #
  # == Related code
  #
  # +Junction::SluggableUrlsHelper+ handles polymorphic "which helper for this record?"
  # logic (+junction_catalog_path+, nested routes not in +PAIRS+, etc.). This file only
  # augments the stock +*_path+ / +*_url+ helpers that Rails generated from named routes.
  #
  module SluggablePathHelperOverrides
    # [route helper name, model class] — only these pairs get the single-arg behavior.
    # The helper must already exist on the engine (defined by +config/routes/+).
    PAIRS = [
      [ :api_path, Api ],
      [ :edit_api_path, Api ],
      [ :component_path, Component ],
      [ :edit_component_path, Component ],
      [ :domain_path, Domain ],
      [ :edit_domain_path, Domain ],
      [ :group_path, Group ],
      [ :edit_group_path, Group ],
      # [ :resource_path, Resource ],
      [ :edit_resource_path, Resource ],
      [ :role_path, Role ],
      [ :edit_role_path, Role ],
      [ :system_path, System ],
      [ :edit_system_path, System ],
      [ :user_path, User ],
      [ :edit_user_path, User ],
      [ :domain_systems_path, Domain ],
      [ :system_apis_path, System ],
      [ :system_components_path, System ],
      [ :system_resources_path, System ],
      [ :group_members_path, Group ],
      [ :search_group_members_path, Group ]
    ].freeze

    # One pair of mixin modules per +RouteSet+ object, keyed by identity so reloads get
    # fresh modules without leaking duplicates across route sets.
    MIXINS_BY_ROUTE_SET = {}.compare_by_identity

    # Keyword args for routes that use +namespace+ and +name+ segments.
    #
    # For persisted records with unsaved changes (e.g. invalid form submit), use the
    # values last stored in the DB (+attribute_in_database+) so links and form actions
    # keep pointing at the canonical URL, not a broken in-memory +name+.
    def self.namespace_name_kwargs(record)
      return { namespace: record.namespace, name: record.name } unless record.respond_to?(:persisted?) && record.respond_to?(:attribute_in_database)

      if record.persisted?
        { namespace: record.attribute_in_database(:namespace), name: record.attribute_in_database(:name) }
      else
        { namespace: record.namespace, name: record.name }
      end
    end

    def self.build_mixin
      Module.new.tap do |mod|
        mod.module_eval do
          PAIRS.each do |meth, klass|
            define_method(meth) do |*args, **kwargs|
              if args.size == 1 && args.first.is_a?(klass)
                super(**Junction::SluggablePathHelperOverrides.namespace_name_kwargs(args.first).merge(kwargs))
              else
                super(*args, **kwargs)
              end
            end

            next unless meth.end_with?("_path")

            # Rails generates +foo_url+ next to +foo_path+; mirror the same single-arg rule.
            url_meth = meth.to_s.sub(/_path\z/, "_url").to_sym
            define_method(url_meth) do |*args, **kwargs|
              if args.size == 1 && args.first.is_a?(klass)
                super(**Junction::SluggablePathHelperOverrides.namespace_name_kwargs(args.first).merge(kwargs))
              else
                super(*args, **kwargs)
              end
            end
          end

          # Member route under a group: +group_member_path(group, user)+ needs +namespace+,
          # +name+ from the group plus +:id+ for the member — not covered by the generic PAIRS loop.
          def group_member_path(*args, **kwargs)
            if args.size == 2 && args[0].is_a?(Group)
              group, member = args
              member_id = member.respond_to?(:id) ? member.id : member
              super(**Junction::SluggablePathHelperOverrides.namespace_name_kwargs(group).merge(id: member_id, **kwargs))
            else
              super(*args, **kwargs)
            end
          end

          def group_member_url(*args, **kwargs)
            if args.size == 2 && args[0].is_a?(Group)
              group, member = args
              member_id = member.respond_to?(:id) ? member.id : member
              super(**Junction::SluggablePathHelperOverrides.namespace_name_kwargs(group).merge(id: member_id, **kwargs))
            else
              super(*args, **kwargs)
            end
          end
        end
      end
    end

    # Prepends the mixins onto this engine's path and URL helper modules (idempotent).
    def self.apply!(route_set)
      mixins = (MIXINS_BY_ROUTE_SET[route_set] ||= { path: build_mixin, url: build_mixin })
      path_helpers = route_set.named_routes.path_helpers_module
      url_helpers = route_set.named_routes.url_helpers_module

      path_helpers.prepend(mixins[:path]) unless path_helpers.ancestors.include?(mixins[:path])
      url_helpers.prepend(mixins[:url]) unless url_helpers.ancestors.include?(mixins[:url])
    end
  end
end
