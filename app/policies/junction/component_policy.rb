# frozen_string_literal: true

module Junction
  class ComponentPolicy < Junction::ApplicationPolicy
    def context
      "components"
    end
  end
end
