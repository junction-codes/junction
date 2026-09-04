# frozen_string_literal: true

module Junction
  # Controller for managing Resource catalog entities.
  class ResourcesController < ApplicationController
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
      Resource
    end

    def index_options
      { available_owners:, available_systems:, available_types: }
    end

    def form_options(_entity)
      { available_owners:, available_systems:, type_options: }
    end

    def create_params
      sanitize_owner_id(sanitize_annotations(params.expect(resource: [
        :description, :image_url, :name, :namespace, :owner_id,
        :system_id, :title, :type, *annotation_param_entries
      ])))
    end

    # Returns a collection of available systems for resources.
    #
    # @return [ActiveRecord::Relation] Collection of systems.
    def available_systems
      System.select(:description, :id, :image_url, :title).order(:title)
    end

    def eager_load_dependencies
      @entity = Resource.includes(:dependencies, :dependents).find_by!(
        namespace: params.expect(:namespace), name: params.expect(:name)
      )
    end
  end
end
