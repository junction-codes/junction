# frozen_string_literal: true

module Junction
  # Controller for managing Component catalog entities.
  class ComponentsController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

    include Breadcrumbs
    include HasDependencies
    include HasDependencyGraph
    include HasDependents
    include HasOwner
    include Paginatable

    # GET /components
    def index
      authorize! Component
      @q = index_scope_for(Component).ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, components = paginate(@q.result)

      render Views::Components::Index.new(
        components:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Component),
        available_lifecycles:,
        available_owners:,
        available_systems:,
        available_types:,
      )
    end

    # GET /components/:id
    def show
      authorize! @entity
      render Views::Components::Show.new(
        component: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        dependencies:,
        dependents:
      )
    end

    # GET /components/new
    def new
      authorize! Component
      render Views::Components::New.new(
        component: Component.new,
        breadcrumbs:,
        available_owners:,
        available_systems:
      )
    end

    # GET /components/:id/edit
    def edit
      authorize! @entity
      render Views::Components::Edit.new(
        component: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_systems:
      )
    end

    # POST /components
    def create
      authorize! Component
      @entity = Component.new(component_params)

      if @entity.save
        redirect_to @entity, success: "Component was successfully created."
      else
        flash.now[:alert] = "There were errors creating the component."
        render Views::Components::New.new(component: @entity, breadcrumbs:, available_owners:, available_systems:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /components/:id
    def update
      authorize! @entity
      if @entity.update(component_params)
        redirect_to @entity, success: "Component was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the component."
        render Views::Components::Edit.new(
          component: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_owners:,
          available_systems:
        ), status: :unprocessable_content
      end
    end

    # DELETE /components/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to components_path, status: :see_other, success: "Component was successfully destroyed."
    end

    private

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
      System.select(:description, :id, :image_url, :name).order(:name)
    end

    # Returns an array of available types for components.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   types.
    def available_types
      Junction::CatalogOptions.kinds.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Component.find(params.expect(:id))
    end

    def eager_load_dependencies
      @entity = Component.includes(:dependencies, :dependents)
                          .find(params.expect(:id))
    end

    def component_params
      sanitize_owner_id(params.expect(component: [
        :component_type, :name, :description, :repository_url, :lifecycle,
        :type, :image_url, :owner_id, :system_id, annotations: {}
      ]))
    end
  end
end
