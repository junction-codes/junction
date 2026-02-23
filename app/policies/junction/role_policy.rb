# frozen_string_literal: true

module Junction
  class RolePolicy < Junction::ApplicationPolicy
    def context
      "roles"
    end
  end
end
