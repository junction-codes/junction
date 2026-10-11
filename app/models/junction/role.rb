# frozen_string_literal: true

module Junction
  # Represents a role used for authorization.
  #
  # @todo System roles are recognized by name. A flag on the record, or a
  #   declared capability, would be sturdier than a string.
  class Role < Entity
    # The system role granting everything registered.
    ADMIN_NAME = "admin"

    # The system role granting everything readable.
    READ_ALL_NAME = "read-all"

    self.default_icon = "shield-check"

    store_accessor :spec, :system_role

    validates :description, presence: true

    has_many :group_roles, dependent: :destroy, class_name: "Junction::GroupRole"
    has_many :groups, through: :group_roles, class_name: "Junction::Group"
    has_many :role_permissions, dependent: :destroy,
             class_name: "Junction::RolePermission"

    before_destroy :prevent_system_role_deletion

    def self.ransackable_associations(auth_object = nil)
      %w[role_permissions]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[description name title]
    end

    # String representation of the permissions stored against this role.
    #
    # A system role has none of its own; see {#effective_permission_strings}.
    #
    # @return [Array<String>] List of permission strings assigned to this role.
    def permission_strings
      role_permissions.order(:permission).pluck(:permission)
    end

    # Everything this role grants.
    #
    # A system role carries no rows of its own: Admin grants whatever the
    # engine and its plugins have registered, and Read all grants the readable
    # half of it. Those sets move as plugins come and go, which is why they
    # are resolved here rather than stored.
    #
    # @return [Array<String>] Every permission the role grants.
    def effective_permission_strings
      return permission_strings unless system?

      case name
      when ADMIN_NAME then registered_permissions.map(&:to_s)
      when READ_ALL_NAME then registered_permissions.select(&:read?).map(&:to_s)
      else permission_strings
      end.sort
    end

    # Whether this role is a system role.
    #
    # @return [Boolean] True if the role is a system role, false otherwise.
    def system?
      ActiveModel::Type::Boolean.new.cast(system_role) == true
    end

    private

    # All registered permissions.
    #
    # @return [Array<Junction::Permission>] Every registered permission.
    def registered_permissions
      Junction::PluginRegistry.permissions
    end

    # Prevents the deletion of system roles.
    #
    # @raise [ActiveRecord::RecordNotDestroyed] If the role is a system role.
    def prevent_system_role_deletion
      throw(:abort) if system?
    end
  end
end
