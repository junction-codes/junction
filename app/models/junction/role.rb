# frozen_string_literal: true

module Junction
  # Represents a role used for authorization.
  class Role < Entity
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

    # String representation of the permissions assigned to this role.
    #
    # @return [Array<String>] List of permission strings assigned to this role.
    #
    # @todo Include system-role expansion.
    def permission_strings
      role_permissions.order(:permission).pluck(:permission)
    end

    # Whether this role is a system role.
    #
    # @return [Boolean] True if the role is a system role, false otherwise.
    def system?
      ActiveModel::Type::Boolean.new.cast(system_role) == true
    end

    private

    # Prevents the deletion of system roles.
    #
    # @raise [ActiveRecord::RecordNotDestroyed] If the role is a system role.
    def prevent_system_role_deletion
      throw(:abort) if system?
    end
  end
end
