# frozen_string_literal: true

module Junction
  # Controller for managing API catalog entities.
  class ApisController < Junction::ApplicationController
    include Junction::HasDependencies
    include Junction::HasDependencyGraph
    include Junction::HasDependents
    include Junction::HasOwner

    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show dependency_graph ]

    # GET /api
    def index
      authorize! Junction::Api
      @q = index_scope_for(Junction::Api).ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Apis::Index.new(
        apis: @q.result,
        query: @q,
        can_create: allowed_to?(:create?, Junction::Api),
        available_lifecycles:,
        available_owners:,
        available_systems:,
        available_types:,
      )
    end

    # GET /api/:id
    def show
      authorize! @entity
      render Views::Apis::Show.new(
        api: @entity,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        dependencies:,
        dependents:
      )
    end

    # GET /api/new
    def new
      authorize! Junction::Api
      render Views::Apis::New.new(api: Junction::Api.new, available_owners:, available_systems:)
    end

    # GET /api/:id/edit
    def edit
      authorize! @entity
      render Views::Apis::Edit.new(
        api: @entity,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_systems:
      )
    end

    # POST /api
    def create
      authorize! Junction::Api
      @entity = Junction::Api.new(api_params)

      if @entity.save
        redirect_to @entity, success: "API was successfully created.", status: :see_other
      else
        flash.now[:alert] = "There were errors creating the API."
        render Views::Apis::New.new(api: @entity, available_owners:, available_systems:),
               status: :unprocessable_content
      end
    end

    # PATH/PUT /api/:id
    def update
      authorize! @entity
      if @entity.update(api_params)
        redirect_to @entity, success: "API was successfully updated.", status: :see_other
      else
        flash.now[:alert] = "There were errors updating the API."
        render Views::Apis::Edit.new(
          api: @entity,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_owners:,
          available_systems:
        ), status: :unprocessable_content
      end
    end

    # DELETE /api/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to apis_path, status: :see_other, alert: "API was successfully destroyed."
    end

    private

    # Returns an array of available lifecycles for apis.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   lifecycles.
    def available_lifecycles
      Junction::CatalogOptions.lifecycles.map { |key, opts| [ opts[:name], key ] }
    end

    # Returns a collection of available systems for apis.
    #
    # @return [ActiveRecord::Relation] Collection of systems.
    def available_systems
      System.select(:description, :id, :image_url, :name).order(:name)
    end

    # Returns an array of available types for apis.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   types.
    def available_types
      Junction::CatalogOptions.apis.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Junction::Api.find(params.expect(:id))
    end

    def eager_load_dependencies
      @entity = Api.includes(:dependencies, :dependents).find(params.expect(:id))
    end

    def api_params
      sanitize_owner_id(params.expect(api: [
        :api_type, :name, :description, :definition, :lifecycle, :type,
        :image_url, :owner_id, :system_id, annotations: {}
      ]))
    end
  end
end
