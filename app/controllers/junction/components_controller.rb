# frozen_string_literal: true

module Junction
  # Controller for managing Component catalog entities.
  class ComponentsController < ApplicationController
    # Declared before Breadcrumbs so the entity is set before any breadcrumb
    # helper runs.
    include CatalogEntityActions
    before_action :eager_load_dependencies, only: %i[dependency_graph]

    include Breadcrumbs
    include CatalogOptionSets
    include HasAnnotations
    include HasDependencyGraph
    include HasOwner
    include Paginatable

    private

    def entity_class
      Component
    end

    def index_options
      {
        available_lifecycles:,
        available_owners:,
        available_systems:,
        available_types:
      }
    end

    def form_options(_entity)
      {
        available_owners:,
        available_systems:,
        type_options:,
        lifecycle_options:
      }
    end

    def create_params
      sanitize_owner_id(sanitize_annotations(params.expect(component: [
        :description, :image_url, :lifecycle, :name,
        :namespace, :owner_id, :repository_url, :system_id, :title, :type,
        *annotation_param_entries
      ])))
    end

    # Returns an array of available lifecycles for components.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   lifecycles.
    def available_lifecycles
      Junction::CatalogOptions.lifecycles.map { |key, opts| [ opts[:name], key ] }
    end

    # Returns a collection of available systems for components.
    #
    # @return [ActiveRecord::Relation] Collection of systems.
    def available_systems
      System.select(:description, :id, :image_url, :title).order(:title)
    end

    # Options for the lifecycle field.
    #
    # @return [Hash] Hash of options.
    def lifecycle_options
      catalog_options_for(
        Junction::CatalogOptions.lifecycles,
        [ Junction::Api, :lifecycle ],
        [ Junction::Component, :lifecycle ]
      )
    end

    def eager_load_dependencies
      @entity = Component.includes(:dependencies, :dependents).find_by!(
        namespace: params.expect(:namespace), name: params.expect(:name)
      )
    end
  end
end
