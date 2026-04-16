# frozen_string_literal: true

module Junction
  # URL helpers for sluggable catalog models (namespace + name segments).
  #
  # Include after Junction::Engine.routes.url_helpers to ensure that named route
  # helpers exist.
  module SluggableUrlsHelper
    # Generic path helper for sluggable catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the entity.
    def junction_catalog_path(record, **options)
      sluggable_path_for(record, :path, **options)
    end

    # Generic URL helper for sluggable catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the URL for.
    # @param options [Hash] Additional options for the URL path.
    # @return [String] URL for the entity.
    def junction_catalog_url(record, **options)
      sluggable_path_for(record, :url, **options)
    end

    # Generic path helper for the edit action on sluggable catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the entity.
    def junction_edit_catalog_path(record, **options)
      sluggable_path_for(record, :path, action: :edit, **options)
    end

    # Form action URL for sluggable catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the URL for.
    # @return [String] URL for the form action.
    def junction_catalog_form_url(record)
      return if record.nil? || !record.persisted?

      junction_catalog_path(record)
    end

    # Generic path helper for the dependency graph on supported catalog
    # entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the dependency graph for the entity.
    def junction_dependency_graph_path(record, **options)
      helper_method = :"#{sluggable_model_name(record)}_dependency_graph_path"
      if respond_to?(helper_method)
        return public_send(helper_method, namespace: record.namespace,
                                          name: record.name, **options)
      end

      raise ArgumentError,
            "Unsupported dependency graph record: #{record.class.name}"
    end

    # Generic path helper for the dependencies on supported catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the dependencies for the entity.
    def junction_dependencies_path(record, **options)
      helper_method = :"#{sluggable_model_name(record)}_dependencies_path"
      if respond_to?(helper_method)
        return public_send(helper_method, namespace: record.namespace,
                                          name: record.name, **options)
      end

      raise ArgumentError,
            "Unsupported dependencies record: #{record.class.name}"
    end

    # Generic path helper for the dependents on supported catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the dependents for the entity.
    def junction_dependents_path(record, **options)
      helper_method = :"#{sluggable_model_name(record)}_dependents_path"
      if respond_to?(helper_method)
        return public_send(helper_method, namespace: record.namespace,
                                          name: record.name, **options)
      end

      raise ArgumentError,
            "Unsupported dependents record: #{record.class.name}"
    end

    # Generic path helper for the search dependencies on supported catalog entities.
    #
    # @param record [ActiveRecord::Base] Record to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the search dependencies for the entity.
    def junction_search_dependencies_path(record, **options)
      helper_method = :"search_#{sluggable_model_name(record)}_dependencies_path"
      if respond_to?(helper_method)
        return public_send(helper_method, namespace: record.namespace,
                                          name: record.name, **options)
      end

      raise ArgumentError,
            "Unsupported search dependencies record: #{record.class.name}"
    end

    def junction_apis_system_path(system, **options)
      system_apis_path(namespace: system.namespace, name: system.name, **options)
    end

    def junction_components_system_path(system, **options)
      system_components_path(namespace: system.namespace, name: system.name, **options)
    end

    def junction_resources_system_path(system, **options)
      system_resources_path(namespace: system.namespace, name: system.name, **options)
    end

    def junction_systems_domain_path(domain, **options)
      domain_systems_path(namespace: domain.namespace, name: domain.name, **options)
    end

    # Path helper for a group's members.
    #
    # @param group [Junction::Group] Group to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the group's members.
    def junction_group_members_path(group, **options)
      group_members_path(namespace: group.namespace, name: group.name, **options)
    end

    # Path helper for the search action for group members.
    #
    # @param group [Junction::Group] Group to generate the path for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the search action
    # for group members.
    def junction_search_group_members_path(group, **options)
      search_group_members_path(namespace: group.namespace, name: group.name, **options)
    end

    # Path helper for a group member.
    #
    # @param group [Junction::Group] Group to generate the path for.
    # @param user [Junction::User, integer] User or user ID to generate the path
    #   for.
    # @param options [Hash] Additional options for the path.
    # @return [String] Path for the group member.
    def junction_group_member_path(group, user, **options)
      member_id = user.respond_to?(:id) ? user.id : user
      group_member_path(namespace: group.namespace, name: group.name, id: member_id, **options)
    end

    private

    # Generate the path or URL for a given record and mode.
    #
    # @param record [ActiveRecord::Base] Record to generate the path or URL for.
    # @param mode [Symbol] Helper mode (:path or :url).
    # @param options [Hash] Additional options for the URL path.
    # @return [String] The path or URL.
    def sluggable_path_for(record, mode, **options)
      helper_method = sluggable_helper_method(
        options.fetch(:action, nil),
        record.model_name.to_s.demodulize.downcase,
        mode
      )

      if respond_to?(helper_method)
        args = Junction::PathHelperOverrides.namespace_name_kwargs(record)
                                                      .merge(options)
        return public_send(helper_method, **args)
      end

      poly_method = :"polymorphic_#{mode == :path ? "path" : "url"}"
      public_send(poly_method, record, **options.compact)
    end

    # Derive the model name from a record.
    #
    # @param record [ActiveRecord::Base] Record to derive the model name from.
    # @return [String] The model name.
    def sluggable_model_name(record)
      record.model_name.to_s.demodulize.downcase
    end

    # Determine the helper method name for a given action and model name.
    #
    # @param action [Symbol] Controller action.
    # @param model_name [String] Model name.
    # @param mode [Symbol] Helper mode (:path or :url).
    # @return [Symbol] The helper method name.
    def sluggable_helper_method(action, model_name, mode)
      helpers = []
      helpers << "edit" if action == :edit
      helpers << model_name
      helpers << mode == :path ? "path" : "url"
      helpers.join("_").to_sym
    end
  end
end
