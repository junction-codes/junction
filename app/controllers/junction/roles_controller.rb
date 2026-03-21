# frozen_string_literal: true

module Junction
  # Controller for managing Roles.
  class RolesController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show ]

    include Breadcrumbs
    include Paginatable

    # GET /roles
    def index
      authorize! Role
      @q = Role.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, roles = paginate(@q.result)

      render Views::Roles::Index.new(
        roles:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Role)
      )
    end

    # GET /roles/:id
    def show
      authorize! @entity
      render Views::Roles::Show.new(
        role: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity) && !@entity.system?
      )
    end

    # GET /roles/new
    def new
      authorize! Role
      @entity = Role.new

      render Views::Roles::New.new(
        role: @entity,
        breadcrumbs:,
        available_permissions: PluginRegistry.permissions
      )
    end

    # POST /roles
    def create
      authorize! Role
      @entity = Role.new(role_params.except(:permission_ids))
      if @entity.save
        sync_role_permissions
        redirect_to @entity, success: "Role was successfully created."
      else
        render Views::Roles::New.new(
          role: @entity,
          breadcrumbs:,
          available_permissions: PluginRegistry.permissions
        ), status: :unprocessable_content
      end
    end

    # GET /roles/:id/edit
    def edit
      authorize! @entity
      render Views::Roles::Edit.new(
        role: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity) && !@entity.system?,
        available_permissions: PluginRegistry.permissions
      )
    end

    # PATCH/PUT /roles/:id
    def update
      authorize! @entity
      if @entity.update(role_params.except(:permission_ids))
        sync_role_permissions unless @entity.system?
        redirect_to @entity, success: "Role was successfully updated."
      else
        render Views::Roles::Edit.new(
          role: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity) && !@entity.system?,
          available_permissions: PluginRegistry.permissions
        ), status: :unprocessable_content
      end
    end

    # DELETE /roles/:id
    def destroy
      authorize! @entity
      if @entity.system?
        redirect_to roles_path, alert: "System roles cannot be deleted.",
                                status: :unprocessable_content
        return
      end

      @entity.destroy!
      redirect_to roles_path, success: "Role was successfully deleted.",
                              status: :see_other
    end

    private

    def set_entity
      @entity = Role.find(params.expect(:id))
    end

    def eager_load_dependencies
      @entity = Role.includes(:role_permissions).find(params.expect(:id))
    end

    def role_params
      params.expect(role: [ :description, :name, { permission_ids: [] } ])
    end

    # Synchronize the permissions assigned to a role.
    #
    # This method updates the role's permissions based on the `permission_ids`
    # received from the params. It will:
    #
    # - Skip system roles (which cannot have their permissions modified).
    # - Add any permissions from params that the role does not currently have.
    # - Remove permissions currently assigned to the role but not present in
    #   params.
    #
    # The role is locked to prevent race conditions when multiple requests are
    # updating the role's permissions at the same time.
    #
    # This ensures the role's permissions exactly match those submitted.
    def sync_role_permissions
      return if @entity.system?

      @entity.with_lock do
        updated = Array(role_params[:permission_ids]).reject(&:blank?)
        current = @entity.role_permissions.pluck(:permission)

        (updated - current).each do |permission|
          @entity.role_permissions.find_or_create_by!(permission:)
        end

        @entity.role_permissions.where(permission: (current - updated)).destroy_all
      end
    end
  end
end
