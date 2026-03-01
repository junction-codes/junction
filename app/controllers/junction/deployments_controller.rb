# frozen_string_literal: true

module Junction
  # Controller for managing Deployments.
  class DeploymentsController < Junction::ApplicationController
    before_action :set_entity, only: %i[ show edit update destroy ]

    # GET /deployments
    def index
      authorize! Junction::Deployment
      @q = Junction::Deployment.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Deployments::Index.new(
        deployments: @q.result,
        query: @q,
        can_create: allowed_to?(:create?, Junction::Deployment),
        available_components:,
        available_environments:,
        available_platforms:
      )
    end

    # GET /deployments/:id
    def show
      authorize! @entity
      render Views::Deployments::Show.new(
        deployment: @entity,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /deployments/new
    def new
      authorize! Junction::Deployment
      render Views::Deployments::New.new(
        deployment: Junction::Deployment.new,
        available_components:
      )
    end

    # GET /deployments/:id/edit
    def edit
      authorize! @entity
      render Views::Deployments::Edit.new(
        deployment: @entity,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_components:
      )
    end

    # POST /deployments
    def create
      authorize! Junction::Deployment
      @entity = Junction::Deployment.new(deployment_params)

      if @entity.save
        redirect_to @entity, success: "Deployment was successfully created."
      else
        flash.now[:alert] = "There were errors creating the deployment."
        render Views::Deployments::New.new(deployment: @entity, available_components:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /deployments/:id
    def update
      authorize! @entity
      if @entity.update(deployment_params)
        redirect_to @entity, success: "Deployment was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the deployment."
        render Views::Deployments::Edit.new(
          deployment: @entity,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_components:
        ), status: :unprocessable_content
      end
    end

    # DELETE /deployments/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to deployments_path, status: :see_other, success: "Deployment was successfully destroyed."
    end

    private

    # Returns a collection of available components for deployments.
    #
    # @return [ActiveRecord::Relation] Collection of components.
    #
    # @todo Only return components that have deployments?
    def available_components
      Component.select(:description, :id, :image_url, :name).order(:name)
    end

    # Returns an array of available environments for deployments.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   environments.
    def available_environments
      Junction::CatalogOptions.environments.map { |key, opts| [ opts[:name], key ] }
    end

    # Returns an array of available platforms for deployments.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   platforms.
    def available_platforms
      Junction::CatalogOptions.platforms.map { |key, opts| [ opts[:name], key ] }
    end

    def set_entity
      @entity = Junction::Deployment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def deployment_params
      params.expect(deployment: [
        :environment, :platform, :location_identifier, :component_id
      ])
    end
  end
end
