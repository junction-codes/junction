# frozen_string_literal: true

module Junction
  # Controller for managing System catalog entities.
  class SystemsController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ show edit update destroy apis
                                         components resources ]

    include Breadcrumbs
    include HasOwner
    include Paginatable

    # GET /systems
    def index
      authorize! System
      @q = index_scope_for(System).ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, systems = paginate(@q.result)

      render Views::Systems::Index.new(
        systems:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, System),
        available_statuses:,
        available_owners:,
        available_domains:
      )
    end

    # GET /systems/:id
    def show
      authorize! @entity
      render Views::Systems::Show.new(
        system: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /systems/new
    def new
      authorize! System
      render Views::Systems::New.new(system: System.new, breadcrumbs:, available_domains:, available_owners:)
    end

    # GET /systems/:id/edit
    def edit
      authorize! @entity
      render Views::Systems::Edit.new(
        system: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_domains:,
        available_owners:
      )
    end

    # POST /systems
    def create
      authorize! System
      @entity = System.new(system_params)

      if @entity.save
        redirect_to junction_catalog_path(@entity), success: "System was successfully created."
      else
        flash.now[:alert] = "There were errors creating the system."
        render Views::Systems::New.new(system: @entity, breadcrumbs:, available_domains:, available_owners:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /systems/:id
    def update
      authorize! @entity
      if @entity.update(system_params)
        redirect_to junction_catalog_path(@entity), success: "System was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the system."
        render Views::Systems::Edit.new(
          system: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_domains:,
          available_owners:
        ), status: :unprocessable_content
      end
    end

    # DELETE /systems/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to systems_path, status: :see_other, success: "System was successfully destroyed."
    end

    # GET /systems/:id/apis
    def apis
      authorize! @entity, to: :show?
      @q = @entity.apis.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, apis = paginate(@q.result)

      render Views::Systems::Apis.new(
        apis:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_apis_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_apis_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_apis_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /systems/:id/components
    def components
      authorize! @entity, to: :show?
      @q = @entity.components.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, components = paginate(@q.result)

      render Views::Systems::Components.new(
        components:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_components_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_components_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_components_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /systems/:id/resources
    def resources
      authorize! @entity, to: :show?
      @q = @entity.resources.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, resources = paginate(@q.result)

      render Views::Systems::Resources.new(
        resources:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_resources_system_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_resources_system_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_resources_system_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    private

    # Returns an array of available domains for systems.
    #
    # @return [Array<Array(String, Integer)>] Array of [name, id] pairs for
    #   domains.
    def available_domains
      Domain.select(:description, :id, :image_url, :title).order(:title)
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
      @entity = System.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    def system_params
      sanitize_owner_id(params.expect(system: [
        :description, :domain_id, :name, :namespace, :owner_id, :status, :title
      ]))
    end
  end
end
