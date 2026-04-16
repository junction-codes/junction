# frozen_string_literal: true

module Junction
  # Extends the engine's generated route helpers so "single model" call sites
  # work.
  #
  # == The problem
  #
  # Catalog entities use "friendly" URLs that look like +/apis/:namespace/:name+
  # (and similar for other resources). Rails generates helpers such as
  # +api_path(namespace:, name:)+, which does not accept +api_path(api)+ with an
  # +Api+ record like the stock Rails helpers do with id based routes. This
  # isn't a problem per-se, but it requires specialized context and isn't
  # immediately obvious.
  #
  # == What we do
  #
  # For each helper method created by Rails (for sluggable catalog entities), we
  # create an override that interprets the calls like +api_path(api)+ and
  # forwards them to +api_path(namespace: ..., name: ...)+. Any other call shape
  # is passed through unchanged.
  #
  # These overrides are prepended to the engine's path and URL helper modules to
  # ensure they are higher in the call stack than the stock Rails helpers, which
  # will be accessible via +super+. We do this through separate modules for path
  # and URL, because Ruby doesn't allow the same module instances to be attached
  # to multiple modules.
  #
  # == Maintaining the list
  #
  # * Add new top-level catalog types to +CATALOG_MEMBERS+ as a bare name symbol
  #   (+:api+, +:domain+, etc.); each resolves to the proper model class
  # * Add nested helpers that do not follow the naming pattern list
  #   +[helper_method, type_symbol]+ in +NESTED_PATH_HELPERS+ (+:domain+ for
  #   +domain_systems_path+, …)
  module PathHelperOverrides
    # Resolves the model class for a catalog entity type.
    #
    # @param type [Symbol] Catalog entity type.
    # @return [Class] The model class.
    def self.catalog_model_class(type)
      Junction.const_get(type.to_s.camelize)
    end

    # Entity types with the standard Rails helpers.
    CATALOG_MEMBERS = %i[
      api
      component
      domain
      group
      resource
      role
      system
      user
    ].freeze

    # Helpers for nested routes that use "friendly" URLs. We need to define
    # these explicitly because they don't follow the naming pattern of the
    # standard Rails helpers, and we can't reliably derive the call signature
    # from the helper name.
    NESTED_PATH_HELPERS = [
      [ :domain_systems_path, :domain ],
      [ :system_apis_path, :system ],
      [ :system_components_path, :system ],
      [ :system_resources_path, :system ],
      [ :group_members_path, :group ],
      [ :search_group_members_path, :group ]
    ].freeze

    # Collect all the helper methods we need to override and pair them with the
    # model class they correspond to.
    PAIRS = (
      CATALOG_MEMBERS.flat_map do |type|
        klass = catalog_model_class(type)
        s = klass.model_name.singular_route_key
        [
          [ :"#{s}_path", klass ],
          [ :"edit_#{s}_path", klass ]
        ]
      end +
      NESTED_PATH_HELPERS.map do |method, type|
        [ method, catalog_model_class(type) ]
      end
    ).freeze

    # One pair of mixin modules per +RouteSet+ object, keyed by identity so that
    # reloads get fresh modules without leaking duplicates across route sets.
    MIXINS_BY_ROUTE_SET = {}.compare_by_identity

    # Keyword arguments for routes that use "friendly" URLs.
    #
    # For persisted records with unsaved changes (e.g. invalid form submit), we
    # use the values last stored in the database instead of
    # the in-memory values. This ensures that links and form actions keep
    # pointing at the canonical URL.
    #
    # @param record [ActiveRecord::Base] Record to generate the keyword
    #   arguments for.
    # @return [Hash] The keyword arguments.
    def self.namespace_name_kwargs(record)
      if record.respond_to?(:persisted?) && record.respond_to?(:attribute_in_database)
        {
          namespace: record.attribute_in_database(:namespace),
          name: record.attribute_in_database(:name)
        }
      else
        { namespace: record.namespace, name: record.name }
      end
    end

    # Builds a mixin module for a given route set.
    #
    # @return [Module] The mixin module.
    def self.build_mixin
      group_model = catalog_model_class(:group)

      Module.new.tap do |mod|
        mod.module_eval do
          PAIRS.each do |method, klass|
            # Define the helper method override.
            define_method(method) do |*args, **kwargs|
              if args.size == 1 && args.first.is_a?(klass)
                super(
                    **Junction::PathHelperOverrides.namespace_name_kwargs(args.first)
                                                   .merge(kwargs)
                  )
              else
                super(*args, **kwargs)
              end
            end

            next unless method.end_with?("_path")

            # Define the matching URL helper method override.
            url_method = method.to_s.sub(/_path\z/, "_url").to_sym
            define_method(url_method) do |*args, **kwargs|
              if args.size == 1 && args.first.is_a?(klass)
                super(
                    **Junction::PathHelperOverrides.namespace_name_kwargs(args.first)
                                                   .merge(kwargs)
                  )
              else
                super(*args, **kwargs)
              end
            end
          end

          # Override for the group member path helper.
          define_method(:group_member_path) do |*args, **kwargs|
            if args.size == 2 && args[0].is_a?(group_model)
              group, member = args
              member_id = member.respond_to?(:id) ? member.id : member
              super(
                **Junction::PathHelperOverrides.namespace_name_kwargs(group)
                                               .merge(id: member_id, **kwargs)
              )
            else
              super(*args, **kwargs)
            end
          end

          # Override for the group member URL helper.
          define_method(:group_member_url) do |*args, **kwargs|
            if args.size == 2 && args[0].is_a?(group_model)
              group, member = args
              member_id = member.respond_to?(:id) ? member.id : member
              super(
                **Junction::PathHelperOverrides.namespace_name_kwargs(group)
                                               .merge(id: member_id, **kwargs)
              )
            else
              super(*args, **kwargs)
            end
          end
        end
      end
    end

    # Prepends the mixins onto this engine's path and URL helper modules.
    #
    # This method is idempotent; it will only prepend the mixins if they are not
    # already prepended.
    #
    # @param route_set [ActionDispatch::Routing::RouteSet] Route set to prepend
    #   the mixins onto.
    def self.apply!(route_set)
      mixins = (MIXINS_BY_ROUTE_SET[route_set] ||= { path: build_mixin, url: build_mixin })
      path_helpers = route_set.named_routes.path_helpers_module
      url_helpers = route_set.named_routes.url_helpers_module

      path_helpers.prepend(mixins[:path]) unless path_helpers.ancestors.include?(mixins[:path])
      url_helpers.prepend(mixins[:url]) unless url_helpers.ancestors.include?(mixins[:url])
    end
  end
end
