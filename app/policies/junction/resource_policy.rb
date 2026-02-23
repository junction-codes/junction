# frozen_string_literal: true

module Junction
  class ResourcePolicy < Junction::ApplicationPolicy
    def context
      "resources"
    end
  end
end
