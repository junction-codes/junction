# frozen_string_literal: true

module Junction
  class SystemPolicy < Junction::ApplicationPolicy
    def context
      "systems"
    end
  end
end
