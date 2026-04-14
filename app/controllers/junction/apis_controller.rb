# frozen_string_literal: true

module Junction
  # Controller for managing API catalog entities.
  class ApisController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ show edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ dependency_graph ]

    include Breadcrumbs
    include HasDependencyGraph
    include HasOwner
    include Paginatable
    include RedirectsLegacySluggableMember

    redirects_legacy_sluggable "/apis", Api

    # GET /api
    def index
      authorize! Api
      @q = index_scope_for(Api).ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, apis = paginate(@q.result)

      render Views::Apis::Index.new(
        apis:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Api),
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
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /api/new
    def new
      authorize! Api
      render Views::Apis::New.new(api: Api.new, breadcrumbs:, available_owners:,
                                  available_systems:)
    end

    # GET /api/:id/edit
    def edit
      authorize! @entity
      render Views::Apis::Edit.new(
        api: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_systems:
      )
    end

    # POST /api
    def create
      authorize! Api
      @entity = Api.new(api_params)

      if @entity.save
        redirect_to junction_catalog_path(@entity), success: "API was successfully created.", status: :see_other
      else
        flash.now[:alert] = "There were errors creating the API."
        render Views::Apis::New.new(api: @entity, breadcrumbs:, available_owners:, available_systems:),
               status: :unprocessable_content
      end
    end

    # PATH/PUT /api/:id
    def update
      authorize! @entity
      if @entity.update(api_params)
        redirect_to junction_catalog_path(@entity), success: "API was successfully updated.", status: :see_other
      else
        flash.now[:alert] = "There were errors updating the API."
        render Views::Apis::Edit.new(
          api: @entity,
          breadcrumbs:,
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

      redirect_to apis_path, status: :see_other, success: "API was successfully destroyed."
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
      System.select(:description, :id, :image_url, :title).order(:title)
    end

    # Returns an array of available types for apis.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   types.
    def available_types
      Junction::CatalogOptions.apis.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Api.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    def eager_load_dependencies
      @entity = Api.includes(:dependencies, :dependents).find_by!(
        namespace: params.expect(:namespace), name: params.expect(:name)
      )
    end

    def api_params
      sanitize_owner_id(params.expect(api: [
        :api_type, :definition, :description, :image_url, :lifecycle, :name,
        :namespace, :owner_id, :system_id, :title, :type, annotations: {}
      ]))
    end
  end
end
