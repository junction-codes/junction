# frozen_string_literal: true

module Junction
  module Permissions
    # Resolves a user's effective permissions from group memberships and
    # group-linked roles, including ancestor inheritance.
    class UserPermissions
      ADMIN_ROLE_NAME = "Admin"
      READ_ALL_ROLE_NAME = "Read all"

      attr_reader :user

      def initialize(user)
        @user = user
      end

      # All permission strings the user has.
      #
      # @return [Set<String>] The user's permission set.
      def permission_set
        @permission_set ||= build_permission_set
      end

      # Whether the user has a specific permission.
      #
      # @param permission [String, Permission] The permission to check.
      # @return [Boolean] True if the user has the permission, false otherwise.
      def has_permission?(permission)
        return false if user.nil?

        permission_set.include?(permission.to_s)
      end

      private

      # Build the user's permission set.
      #
      # This method collects all permissions from the user's roles, including
      # ancestor roles, and returns them as a set of permission strings.
      #
      # @return [Set<String>] The user's permission set.
      def build_permission_set
        return Set.new if user.nil?

        set = Set.new
        user_roles.each do |role|
          set.merge(role_permissions(role))
        end
        set
      end

      # Collect the user's roles, including ancestor roles.
      #
      # @return [Array<Role>] The user's roles.
      #
      # @todo Review for performance.
      def user_roles
        group_ids = user.group_memberships.includes(group: :parent)
                        .map(&:group).flat_map(&:self_and_ancestors).map(&:id)
                        .uniq
        return [] if group_ids.empty?

        role_names = Junction::Group.where(id: group_ids).pluck(:annotations)
                                    .flat_map do |annotation|
          annotation.is_a?(Hash) ? annotation[CorePlugin::ANNOTATION_GROUP_ROLE] : []
        end.compact.uniq
        return [] if role_names.empty?

        Junction::Role.where(name: role_names)
      end

      # Get the permissions for a specific role.
      #
      # @param role [Role] Role to get permissions for.
      # @return [Set<String>] The role's permissions.
      #
      # @todo Make this more robust for system roles, rather than relying on
      #       hard-coded role names.
      def role_permissions(role)
        case role.name
        when ADMIN_ROLE_NAME
          all_registry_permissions
        when READ_ALL_ROLE_NAME
          read_only_registry_permissions
        else
          role.permission_strings.to_set
        end
      end

      def all_registry_permissions
        Junction::PluginRegistry.permissions.map(&:to_s).to_set
      end

      def read_only_registry_permissions
        Junction::PluginRegistry.permissions.select(&:read?).map(&:to_s).to_set
      end
    end
  end
end
