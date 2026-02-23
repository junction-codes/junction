# frozen_string_literal: true

module Junction
  # Controller for managing System catalog entities.
  class SystemsController < Junction::ApplicationController
    include Junction::HasOwner

    before_action :set_entity, only: %i[ show edit update destroy dependency_graph ]

    # GET /systems
    def index
      authorize! Junction::System
      @q = Junction::System.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Systems::Index.new(
        systems: @q.result,
        query: @q,
        available_statuses:,
        available_owners:,
        available_domains:
      )
    end

    # GET /systems/:id
    def show
      authorize! @system
      render Views::Systems::Show.new(
        system: @system,
      )
    end

    # GET /systems/new
    def new
      authorize! Junction::System
      render Views::Systems::New.new(system: Junction::System.new, available_domains:, available_owners:)
    end

    # GET /systems/:id/edit
    def edit
      authorize! @system
      render Views::Systems::Edit.new(system: @system, available_domains:, available_owners:)
    end

    # POST /systems
    def create
      authorize! Junction::System
      @system = Junction::System.new(system_params)

      if @system.save
        redirect_to @system, success: "System was successfully created."
      else
        flash.now[:alert] = "There were errors creating the system."
        render Views::Systems::New.new(system: @system, available_domains:, available_owners:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /systems/:id
    def update
      authorize! @system
      if @system.update(system_params)
        redirect_to @system, success: "System was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the system."
        render Views::Systems::Edit.new(system: @system, available_domains:, available_owners:),
               status: :unprocessable_content
      end
    end

    # DELETE /systems/:id
    def destroy
      authorize! @system
      @system.destroy!

      redirect_to systems_path, status: :see_other, alert: "System was successfully destroyed."
    end

    # GET /systems/:id/dependency_graph
    #
    # @todo Break this up into smaller methods for better readability.
    def dependency_graph
      authorize! @system
      graph_data = DependencyGraphService.new(model: @system).build
      render json: graph_data
    end

    private

    # Returns an array of available domains for systems.
    #
    # @return [Array<Array(String, Integer)>] Array of [name, id] pairs for
    #   domains.
    def available_domains
      Domain.select(:description, :id, :image_url, :name).order(:name)
    end

    # Returns an array of available statuses for systems.
    #
    # @return [Array<Array(String, String)>] Array of [label, value] pairs for
    #   statuses.
    def available_statuses
      System.validators_on(:status).find do |v|
        v.is_a?(ActiveModel::Validations::InclusionValidator)
      end&.options[:in]&.map { |s| [ s.capitalize, s ] } || []
    end

    def set_entity
      @system = Junction::System.find(params.expect(:id))
    end

    def system_params
      sanitize_owner_id(params.expect(system: [
        :name, :description, :status, :domain_id, :owner_id
      ]))
    end
  end
end
