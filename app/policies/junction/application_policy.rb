# frozen_string_literal: true

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

    # Determine if the user has the given access level for the given context.
    #
    # @param context [String] Context to check access for.
    # @param access [String] Access level to check.
    # @param entity [ApplicationRecord] Entity to validate ownership for "owned"
    #   permissions.
    # @return [Boolean] Whether the user has the requested access.
    def allowed_access?(context, access, entity: nil)
      prefix = "#{self.class::DOMAIN}/#{context}"

      allow = allowed_permission?("#{prefix}.all.#{access}")
      return allow if allow || entity.nil?

      allowed_permission?("#{prefix}.owned.#{access}", entity:)
    end

    def create?
      allowed_access?(context, Permission::Access::WRITE)
    end

    def destroy?
      allowed_access?(context, Permission::Access::DESTROY, entity: record)
    end

    def index?
      allowed_access?(context, Permission::Access::READ)
    end

    def show?
      allowed_access?(context, Permission::Access::READ, entity: record)
    end

    def update?
      allowed_access?(context, Permission::Access::WRITE, entity: record)
    end

    private

    # Service object for resolving the user's effective permissions.
    #
    # @return [Permissions::UserPermissions] The user's permissions.
    def permissions
      @permissions ||= Permissions::UserPermissions.new(user)
    end
  end
end
