# frozen_string_literal: true

module Junction
  module Roles
    # Builds an overview of all roles and their permissions.
    #
    # Most of it's about reach. A role carries a permission count, the groups
    # granted it, and the number of people those groups work out to once group
    # ancestry is resolved.
    class Overview
      # A permission a role doesn't hold.
      NOT_GRANTED = :not_granted

      # A permission nothing registers, which no role can hold.
      NOT_REGISTERED = :not_registered

      # The summary of a role as the index pane lists it.
      Summary = Struct.new(:id, :record, :title, :description, :system,
                           :permissions, :groups, keyword_init: true)

      # Returns the id a role's pane and frame are addressed by.
      #
      # A role's name is unique within its namespace, not across the catalog,
      # so two roles can both be called "ops". The namespace is part of the id
      # to keep their panes apart.
      #
      # @param role [Junction::Role] The role.
      # @return [String] The id.
      def self.pane_id(role)
        "#{role.namespace}-#{role.name}"
      end

      # Returns a summary of every role, ordered by title.
      #
      # @return [Array<Summary>] Role summaries.
      def roles
        @roles ||= Junction::Role.includes(:role_permissions, :groups)
                                 .order(:title).map { |role| summarize(role) }
      end

      # Returns the roles the engine ships, which have no editable
      # permission list.
      #
      # @return [Array<Summary>] System role summaries.
      def system_roles
        roles.select(&:system)
      end

      # Returns the roles this catalog defined for itself.
      #
      # @return [Array<Summary>] Custom role summaries.
      def custom_roles
        roles.reject(&:system)
      end

      # Returns every permission the engine and its plugins register.
      #
      # @return [Array<Junction::Permission>] The permissions.
      def registered_permissions
        @registered_permissions ||= Junction::PluginRegistry.permissions
      end

      # Counts the plugins registering permissions of their own.
      #
      # @return [Integer] The number of plugins that register permissions.
      def plugins_registering
        Junction::PluginRegistry.plugins_registering_permissions.size
      end

      # Counts what a role reaches, for the editor's metadata card.
      #
      # The editor needs the two totals and none of the matrix {#detail}
      # builds, so this runs the group and membership queries on their own.
      #
      # @param role [Junction::Role] The role.
      # @return [Hash] The counts.
      # @option return [Integer] :groups The groups granted the role.
      # @option return [Integer] :people The people those groups work out to.
      def reach(role)
        groups = role.groups.to_a

        { groups: groups.size, people: people_reached(groups) }
      end

      # Builds everything the detail pane draws for one role.
      #
      # @param role [Junction::Role] The role.
      # @return [Hash] What the detail pane draws.
      def detail(role)
        granted = role.groups.to_a
        members = membership_counts(granted.map(&:id))
        permissions = granted_permissions(role)

        {
          role:,
          id: self.class.pane_id(role),
          permissions:,
          registered_total: registered_permissions.size,
          matrix: matrix_for(permissions),
          groups: granted.map { |group| group_summary(group, members) },
          people: people_reached(granted)
        }
      end

      private

      # Returns what a role grants and this instance still registers.
      #
      # A stored permission outlives the plugin that registered it, so a role
      # can carry strings nothing recognises any more. Those are left out:
      # they grant nothing, and counting them would read as more access than
      # the role has.
      #
      # @param role [Junction::Role] The role.
      # @return [Array<String>] The permissions, sorted.
      def granted_permissions(role)
        held = if role.system?
                 role.effective_permission_strings
        else
                 role.role_permissions.map { |row| row.permission.to_s }
        end

        (held & registered_strings).sort
      end

      # Returns every registered permission as a string, for membership tests.
      #
      # @return [Array<String>] The permission strings.
      def registered_strings
        @registered_strings ||= registered_permissions.map(&:to_s)
      end

      # Summarizes a role for the index pane.
      #
      # @param role [Junction::Role] The role.
      # @return [Summary] The summary.
      def summarize(role)
        Summary.new(
          id: self.class.pane_id(role),
          record: role,
          title: role.title,
          description: role.description,
          system: role.system?,
          permissions: granted_permissions(role).size,
          groups: role.groups.size
        )
      end

      # Builds the permission matrix: one row per domain and context the role
      # has any access to, and what that access is.
      #
      # @param permissions [Array<String>] What the role grants.
      # @return [Array<Hash>] `{ context:, read:, write:, destroy: }` rows,
      #   each access holding an ownership scope, {NOT_GRANTED} or
      #   {NOT_REGISTERED}.
      def matrix_for(permissions)
        parsed = permissions.filter_map { |string| Permission.parse(string) }

        parsed.group_by(&:context_path).sort.map do |context, permissions|
          { context: }.merge(
            Permission::Access::VALUES.to_h do |access|
              [ access.to_sym, cell_for(context, permissions, access) ]
            end
          )
        end
      end

      # Returns what a role may do at one access level.
      #
      # @param context [String] The domain and context.
      # @param permissions [Array<Junction::Permission>] The role's permissions
      # @param access [String] The access level.
      # @return [String, Symbol] Permission ownership scope, or why there is
      #   none.
      def cell_for(context, permissions, access)
        held = permissions.select { |permission| permission.access.to_s == access.to_s }
        return held.any?(&:all?) ? Permission::Ownership::ALL : Permission::Ownership::OWNED if held.any?

        registered?(context, access) ? NOT_GRANTED : NOT_REGISTERED
      end

      # Determines whether a permission is registered for a given context and
      # access level.
      #
      # @param context [String] The domain and context.
      # @param access [String] The access level.
      # @return [Boolean] Whether the permission is registered.
      def registered?(context, access)
        registered_by_context.fetch(context, []).include?(access.to_s)
      end

      # Returns the access levels registered for each context.
      #
      # @return [Hash<String, Array<String>>] Access levels by context.
      def registered_by_context
        @registered_by_context ||=
          registered_permissions.group_by(&:context_path)
                                .transform_values { |permissions| permissions.map { |p| p.access.to_s }.uniq }
      end

      # Summarizes a group that holds a role.
      #
      # @param group [Junction::Group] The group.
      # @param members [Hash<Integer, Integer>] Membership counts by group id.
      # @return [Hash] The group and its membership count.
      def group_summary(group, members)
        { group:, members: members.fetch(group.id, 0) }
      end

      # Counts the members of every group holding the role, in one query.
      #
      # @param ids [Array<Integer>] The group ids.
      # @return [Hash<Integer, Integer>] Membership counts by group id.
      def membership_counts(ids)
        return {} if ids.empty?

        Junction::GroupMembership.where(group_id: ids).group(:group_id).count
      end

      # Counts the people a role reaches.
      #
      # A role granted to a group reaches that group's members and everyone in
      # the groups beneath it, since a person inherits from every group they
      # belong to and from those groups' ancestors. Counted over the whole
      # tree rather than per group, so somebody in two of them counts once.
      #
      # @param groups [Array<Junction::Group>] The groups holding the role.
      # @return [Integer] Number of users reached by the role.
      def people_reached(groups)
        return 0 if groups.empty?

        ids = groups.flat_map { |group| [ group.id, *group.descendant_ids ] }.uniq

        Junction::GroupMembership.where(group_id: ids).distinct.count(:user_id)
      end
    end
  end
end
