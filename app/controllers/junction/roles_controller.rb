# frozen_string_literal: true

module Junction
  # Controller for managing Roles.
  class RolesController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[show edit update destroy]

    include Breadcrumbs

    # GET /roles
    def index
      authorize! Role

      render Views::Roles::Index.new(
        overview: Junction::Roles::Overview.new,
        breadcrumbs:,
        can_create: allowed_to?(:create?, Role)
      )
    end

    # GET /roles/:id
    def show
      authorize! @entity
      return render_role_pane if turbo_frame_request?

      render Views::Roles::Index.new(
        overview: Junction::Roles::Overview.new,
        open: Junction::Roles::Overview.pane_id(@entity),
        breadcrumbs:,
        can_create: allowed_to?(:create?, Role)
      )
    end

    # GET /roles/new
    def new
      authorize! Role
      @entity = Role.new

      render new_view
    end

    # POST /roles
    def create
      authorize! Role
      @entity = Role.new(role_params.except(:permission_ids))
      if @entity.save
        sync_role_permissions
        redirect_to junction_catalog_path(@entity), success: "Role was successfully created."
      else
        render new_view(submitted: submitted_permissions), status: :unprocessable_content
      end
    end

    # GET /roles/:id/edit
    def edit
      authorize! @entity

      render edit_view
    end

    # PATCH/PUT /roles/:id
    def update
      authorize! @entity
      if @entity.update(role_params.except(:permission_ids))
        sync_role_permissions unless @entity.system?
        redirect_to junction_catalog_path(@entity), success: "Role was successfully updated."
      else
        render edit_view(submitted: submitted_permissions), status: :unprocessable_content
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

    # Builds the create page, for a first visit and for a rejected save alike.
    #
    # @param submitted [Array<String>] The permissions a rejected save sent.
    # @return [Views::Roles::New] The view.
    def new_view(submitted: nil)
      Views::Roles::New.new(
        role: @entity,
        breadcrumbs:,
        submitted:,
        available_permissions: PluginRegistry.permissions
      )
    end

    # Builds the edit page, for a first visit and for a rejected save alike.
    #
    # The rail tells the user what a save is about to affect, so a failed
    # update has to rebuild it: rendered without the counts, the metadata card
    # would report no groups and no people exactly when the user is deciding
    # whether to retry.
    #
    # @param submitted [Array<String>] The permissions a rejected save sent.
    # @return [Views::Roles::Edit] The view.
    def edit_view(submitted: nil)
      Views::Roles::Edit.new(
        role: @entity,
        breadcrumbs:,
        submitted:,
        reach: Junction::Roles::Overview.new.reach(@entity),
        can_destroy: allowed_to?(:destroy?, @entity) && !@entity.system?,
        available_permissions: PluginRegistry.permissions
      )
    end

    # Returns the permissions a rejected save sent.
    #
    # The role's permissions are written only once the role itself validates,
    # so after a rejection they exist nowhere but in the params. An empty array
    # is a real answer, the user cleared every box, so we don't fall back to
    # what's stored for the role.
    #
    # @return [Array<String>] The permission strings.
    def submitted_permissions
      Array(role_params[:permission_ids]).reject(&:blank?)
    end

    # Renders one role's detail pane, for the frame the roles page asks for.
    def render_role_pane
      render Views::Roles::Show.new(
        detail: Junction::Roles::Overview.new.detail(@entity),
        can_edit: allowed_to?(:update?, @entity)
      )
    end

    def breadcrumb_section
      [ { label: t("junction.breadcrumbs.settings") } ]
    end

    def set_entity
      @entity = Role.includes(:role_permissions).find_by!(
        namespace: params.expect(:namespace), name: params.expect(:name)
      )
    end

    def role_params
      params.expect(role: [ :description, :name, :namespace, :title, { permission_ids: [] } ])
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
    # Only permissions the form offered are removed. A stored permission
    # outlives the plugin that registered it, and one nothing registers any
    # more has no checkbox, so it was never a box the user cleared. Dropping
    # it here would delete a grant the editor never showed them, and reinstall
    # the plugin to find it gone.
    #
    # Additions similarly only affect permissions the form offered. If the form
    # was submitted with permissions not in the registry, those permissions are
    # ignored.
    #
    # The role is locked to prevent race conditions when multiple requests are
    # updating the role's permissions at the same time.
    def sync_role_permissions
      return if @entity.system?

      @entity.with_lock do
        offered = PluginRegistry.permissions.map(&:to_s)
        updated = Array(role_params[:permission_ids]).reject(&:blank?)
        current = @entity.role_permissions.pluck(:permission)

        ((updated & offered) - current).each do |permission|
          @entity.role_permissions.find_or_create_by!(permission:)
        end

        @entity.role_permissions.where(permission: (current - updated) & offered).destroy_all
      end
    end
  end
end
