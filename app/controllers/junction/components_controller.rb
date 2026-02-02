# frozen_string_literal: true

module Junction
  # Controller for managing Component catalog entities.
  class ComponentsController < Junction::ApplicationController
    include Junction::HasDependencies
    include Junction::HasDependencyGraph
    include Junction::HasDependents

    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

    # GET /components
    def index
      @q = Junction::Component.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Components::Index.new(
        components: @q.result,
        query: @q,
        available_lifecycles:,
        available_owners:,
        available_systems:,
        available_types:,
      )
    end

    # GET /components/:id
    def show
      render Views::Components::Show.new(component: @entity, dependencies:, dependents:)
    end

    # GET /components/new
    def new
      render Views::Components::New.new(
        component: Junction::Component.new,
        available_owners:,
        available_systems:
      )
    end

    # GET /components/:id/edit
    def edit
      render Views::Components::Edit.new(
        component: @entity,
        available_owners:,
        available_systems:
      )
    end

    # POST /components
    def create
      @entity = Junction::Component.new(component_params)

      if @entity.save
        redirect_to @entity, success: "Component was successfully created."
      else
        flash.now[:alert] = "There were errors creating the component."
        render Views::Components::New.new(component: @entity, available_owners:, available_systems:), status: :unprocessable_content
      end
    end

    # PATCH/PUT /components/:id
    def update
      if @entity.update(component_params)
        redirect_to @entity, success: "Component was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the component."
        render Views::Components::Edit.new(component: @entity, available_owners:, available_systems:), status: :unprocessable_content
      end
    end

    # DELETE /components/:id
    def destroy
      @entity.destroy!

      redirect_to components_path, status: :see_other, alert: "Component was successfully destroyed."
    end

    private

    # Returns an array of available lifecycles for components.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   lifecycles.
    def available_lifecycles
      Junction::CatalogOptions.lifecycles.map { |key, opts| [ opts[:name], key ] }
    end

    # Returns a collection of available owners for components.
    #
    # @return [ActiveRecord::Relation] Collection of owners.
    def available_owners
      Group.select(:description, :id, :image_url, :name).order(:name)
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
      @entity = Junction::Component.find(params.expect(:id))
    end

    def eager_load_dependencies
      @entity = Component.includes(:dependencies, :dependents)
                          .find(params.expect(:id))
    end

    def component_params
      params.expect(component: [ :name, :description, :repository_url, :lifecycle, :type, :image_url, :owner_id, :system_id, annotations: {} ])
    end
  end
end
