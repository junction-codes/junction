# frozen_string_literal: true

module Junction
  class UserPolicy < Junction::ApplicationPolicy
    def context
      "users"
    end
  end
end
