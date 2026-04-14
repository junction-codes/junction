# frozen_string_literal: true

module Junction
  # Controller for managing Groups.
  class GroupsController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ show edit update destroy ]

    include Breadcrumbs
    include Paginatable

    # GET /groups
    def index
      authorize! Group
      @q = Group.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, groups = paginate(@q.result)

      render Views::Groups::Index.new(
        groups:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Group),
        available_types:,
      )
    end

    # GET /groups/:id
    def show
      authorize! @entity
      render Views::Groups::Show.new(
        group: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        can_view_members: allowed_to?(:index_all?, User)
      )
    end

    # GET /groups/new
    def new
      authorize! Group
      render Views::Groups::New.new(group: Group.new, breadcrumbs:, available_parents:)
    end

    # GET /groups/:id/edit
    def edit
      authorize! @entity
      render Views::Groups::Edit.new(
        group: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_parents:
      )
    end

    # POST /groups
    def create
      authorize! Group
      @entity = Group.new(group_params)

      if @entity.save
        redirect_to junction_catalog_path(@entity), success: "Group was successfully created."
      else
        flash.now[:alert] = "There were errors creating the group."
        render Views::Groups::New.new(group: @entity, breadcrumbs:, available_parents:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /groups/:id
    def update
      authorize! @entity
      if @entity.update(group_params)
        redirect_to junction_catalog_path(@entity), success: "Group was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the group."
        render Views::Groups::Edit.new(
          group: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_parents:
        ), status: :unprocessable_content
      end
    end

    # DELETE /groups/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to groups_path, status: :see_other, success: "Group was successfully destroyed."
    end

    private

    # Returns a collection of available parents for groups.
    #
    # @return [ActiveRecord::Relation] Collection of parents.
    def available_parents
      Group.select(:description, :id, :image_url, :title).order(:title)
    end

    # Returns an array of available types for groups.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   types.
    def available_types
      CatalogOptions.group_types.map { |key, opts| [ opts[:name], key ] }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_entity
      @entity = Group.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    # Only allow a list of trusted parameters through.
    #
    # @return [Hash] The permitted parameters.
    #
    # @todo We should support some sanitation of annotations, particularly those
    # that are used for access controls.
    def group_params
      params.expect(group: [
        :description, :email, :group_type, :image_url, :name, :namespace,
        :parent_id, :title, :type, annotations: {}
      ])
    end
  end
end
