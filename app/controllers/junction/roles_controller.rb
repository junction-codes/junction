# frozen_string_literal: true

module Junction
  # Controller for managing Roles.
  class RolesController < Junction::ApplicationController
    before_action :set_role, only: %i[ edit update destroy ]
    before_action :eager_load_dependencies, only: %i[ show ]

    # GET /roles
    def index
      authorize! Junction::Role
      @q = Junction::Role.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Roles::Index.new(roles: @q.result, query: @q)
    end

    # GET /roles/:id
    def show
      authorize! @role
      render Views::Roles::Show.new(role: @role)
    end

    # GET /roles/new
    def new
      authorize! Junction::Role
      @role = Junction::Role.new

      render Views::Roles::New.new(
        role: @role,
        available_permissions: Junction::PluginRegistry.permissions
      )
    end

    # POST /roles
    def create
      authorize! Junction::Role
      @role = Junction::Role.new(role_params.except(:permission_ids))
      if @role.save
        sync_role_permissions
        redirect_to @role, success: "Role was successfully created."
      else
        render Views::Roles::New.new(
          role: @role,
          available_permissions: Junction::PluginRegistry.permissions
        ), status: :unprocessable_content
      end
    end

    # GET /roles/:id/edit
    def edit
      authorize! @role
      render Views::Roles::Edit.new(
        role: @role,
        available_permissions: Junction::PluginRegistry.permissions
      )
    end

    # PATCH/PUT /roles/:id
    def update
      authorize! @role
      if @role.update(role_params.except(:permission_ids))
        sync_role_permissions unless @role.system?
        redirect_to @role, success: "Role was successfully updated."
      else
        render Views::Roles::Edit.new(
          role: @role,
          available_permissions: Junction::PluginRegistry.permissions
        ), status: :unprocessable_content
      end
    end

    # DELETE /roles/:id
    def destroy
      authorize! @role
      if @role.system?
        redirect_to roles_path, alert: "System roles cannot be deleted.",
                                status: :unprocessable_entity
        return
      end

      @role.destroy!
      redirect_to roles_path, alert: "Role was successfully deleted.",
                              status: :see_other
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

    def eager_load_dependencies
      @role = Role.includes(:role_permissions).find(params.expect(:id))
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
    # This ensures the role's permissions exactly match those submitted.
    def sync_role_permissions
      return if @role.system?

      permitted = Array(params.dig(:role, :permission_ids)).reject(&:blank?)
      current = @role.role_permissions.pluck(:permission)
      to_add = permitted - current
      to_remove = current - permitted

      to_add.each do |permission|
        @role.role_permissions.find_or_create_by!(permission:)
      end

      @role.role_permissions.where(permission: to_remove).destroy_all
    end
  end
end
