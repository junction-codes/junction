# frozen_string_literal: true

module Junction
  class ApiPolicy < Junction::ApplicationPolicy
    def context
      "apis"
    end
  end
end
