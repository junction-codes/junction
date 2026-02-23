# frozen_string_literal: true

module Junction
  class DashboardPolicy < Junction::ApplicationPolicy
    def context
      "dashboards"
    end
  end
end
