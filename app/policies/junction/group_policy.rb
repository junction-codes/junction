# frozen_string_literal: true

module Junction
  class GroupPolicy < Junction::ApplicationPolicy
    def context
      "groups"
    end
  end
end
