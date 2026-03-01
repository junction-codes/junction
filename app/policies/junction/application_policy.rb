# frozen_string_literal: true

require "action_policy"

module Junction
  # Base policy for all Junction authorization policies.
  #
  # @abstract
  class ApplicationPolicy < ActionPolicy::Base
    DOMAIN = "junction.codes"

    alias_rule :edit?, to: :update?

    # Context of the current policy.
    #
    # @return [String] Context of the current policy.
    #
    # @raise [NotImplementedError] If not overridden in subclasses.
    def context
      raise NotImplementedError, "#{self.class} must define #context"
    end

    # Check if the current user has the given permission, and optionally
    # enforce ownership for "owned" permissions.
    #
    # @param permission [Junction::Permission, String] Permission to check.
    # @param entity [ApplicationRecord] Entity to validate ownership for "owned"
    #   permissions.
    # @return [Boolean]
    def allowed_permission?(permission, entity: nil)
      return false if user.nil?

      return false unless permissions.has_permission?(permission)

      return true if entity.nil?

      perm = permission.is_a?(Permission) ? permission : Permission.parse(permission)
      return true if perm.nil? || perm.all?

      return false if !entity.respond_to?(:owner_id) || entity.owner_id.blank?

      user.deep_group_ids.include?(entity.owner_id)
    end

    # Determine if the user has the given access.
    #
    # @param access [Junction::Permission::Access] Access level to check.
    # @param entity [ApplicationRecord] Entity to validate ownership for "owned"
    #   permissions.
    # @return [Boolean] Whether the user has the requested access.
    def allowed_access?(access, entity: nil)
      allow = allowed_permission?("#{permission_prefix}.all.#{access}")
      return allow if allow || entity.nil?

      allowed_permission?("#{permission_prefix}.owned.#{access}", entity:)
    end

    def create?
      create_all? || create_owned?
    end

    # Whether the user may create entities that they don't own.
    #
    # @return [Boolean]
    def create_all?
      allowed_permission?("#{permission_prefix}.all.#{Permission::Access::WRITE}")
    end

    # Whether the user may create entities that they will own.
    #
    # When true and create_all? is false, the new entity's owner should be
    # restricted to the groups in the user's group hierarchy.
    #
    # @return [Boolean]
    def create_owned?
      allowed_permission?("#{permission_prefix}.owned.#{Permission::Access::WRITE}")
    end

    def destroy?
      allowed_access?(Permission::Access::DESTROY, entity: record)
    end

    def index?
      index_all? || index_owned?
    end

    # Whether the user may see all entities in the index (has .all.read).
    #
    # @return [Boolean]
    def index_all?
      allowed_access?(Permission::Access::READ)
    end

    # Whether the user may see owned entities in the index (has .owned.read).
    #
    # When true and index_all? is false, the index list should be scoped to
    # entities owned by the user's groups (for entities with an owner_id).
    #
    # @return [Boolean]
    def index_owned?
      allowed_permission?("#{permission_prefix}.owned.#{Permission::Access::READ}")
    end

    def show?
      allowed_access?(Permission::Access::READ, entity: record)
    end

    def update?
      allowed_access?(Permission::Access::WRITE, entity: record)
    end

    private

    # Service object for resolving the user's effective permissions.
    #
    # @return [Permissions::UserPermissions] The user's permissions.
    def permissions
      @permissions ||= Permissions::UserPermissions.new(user)
    end

    # Prefix for permission strings for the current context.
    #
    # @return [String] Prefix for permission strings.
    def permission_prefix
      @permission_prefix ||= "#{self.class::DOMAIN}/#{context}"
    end
  end
end
