# frozen_string_literal: true

module Junction
  # Represents a permission assigned to a role.
  class RolePermission < ApplicationRecord
    validates :permission, presence: true, uniqueness: { scope: :role_id }
    validate :permission_format_validation

    composed_of :permission,
      class_name: "Junction::Permission",
      mapping: { permission: :to_s },
      constructor: :parse

    belongs_to :role, class_name: "Junction::Role"

    def self.ransackable_attributes(auth_object = nil)
      %w[permission]
    end

    private

    # Validates that the permission string is a valid format.
    #
    # @return [Boolean] Whether the permission string is a valid format.
    def permission_format_validation
      value = read_attribute(:permission)
      return if value.blank? || Permission.parse(value).present?

      errors.add(:permission, "is not a valid permission format (expected domain/context.ownership.access)")
    end
  end
end
