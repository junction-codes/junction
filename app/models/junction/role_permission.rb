# frozen_string_literal: true

module Junction
  # Represents a permission assigned to a role.
  class RolePermission < ApplicationRecord
    validates :permission, presence: true, uniqueness: { scope: :role_id }

    composed_of :permission,
      class_name: "Junction::Permission",
      mapping: { permission: :to_s },
      constructor: :parse

    belongs_to :role, class_name: "Junction::Role"

    def self.ransackable_attributes(auth_object = nil)
      %w[permission]
    end
  end
end
