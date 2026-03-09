# frozen_string_literal: true

module Junction
  # Controller for managing Groups.
  class GroupsController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ show edit update destroy ]

    include Breadcrumbs

    # GET /groups
    def index
      authorize! Group
      @q = Group.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Groups::Index.new(
        groups: @q.result,
        query: @q,
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
        can_destroy: allowed_to?(:destroy?, @entity)
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
        redirect_to @entity, success: "Group was successfully created."
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
        redirect_to @entity, success: "Group was successfully updated."
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
      Group.select(:description, :id, :image_url, :name).order(:name)
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
      @entity = Group.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    #
    # @return [Hash] The permitted parameters.
    #
    # @todo We should support some sanitation of annotations, particularly those
    # that are used for access controls.
    def group_params
      params.expect(group: [
        :description, :name, :email, :image_url, :parent_id, :type, annotations: {}
      ])
    end
  end
end
