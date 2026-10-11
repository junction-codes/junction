# frozen_string_literal: true

module Junction
  module Permissions
    # Resolves a user's effective permissions from group memberships and
    # group-linked roles, including ancestor inheritance.
    class UserPermissions
      include InstrumentationHelper

      # Aliased for callers that predate the model's own constants.
      ADMIN_ROLE_NAME = Junction::Role::ADMIN_NAME
      READ_ALL_ROLE_NAME = Junction::Role::READ_ALL_NAME

      attr_reader :user

      # Initializes the resolver for one user.
      #
      # @param user [Junction::User] The user whose permissions are resolved.
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

        trace "junction.permissions.check", "junction.permission" => permission.to_s do |span|
          result = permission_set.include?(permission.to_s)
          span.set_attribute("junction.permission.granted", result)
          result
        end
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

        trace "junction.permissions.build" do |span|
          result = user_roles.each_with_object(Set.new) do |role, set|
            set.merge(role_permissions(role))
          end

          span.set_attribute("junction.permission.count", result.size)
          result
        end
      end

      # Collect the user's roles, including those granted to ancestor groups.
      #
      # @return [ActiveRecord::Relation<Role>] The user's roles.
      def user_roles
        group_ids = user.deep_group_ids
        return Junction::Role.none if group_ids.empty?

        Junction::Role.joins(:group_roles)
                      .where(junction_group_roles: { group_id: group_ids })
                      .distinct
      end

      # Get the permissions for a specific role.
      #
      # @param role [Role] Role to get permissions for.
      # @return [Set<String>] The role's permissions.
      #
      def role_permissions(role)
        role.effective_permission_strings.to_set
      end
    end
  end
end
