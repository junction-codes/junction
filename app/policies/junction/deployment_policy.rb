# frozen_string_literal: true

module Junction
  class DeploymentPolicy < Junction::ApplicationPolicy
    def context
      "deployments"
    end
  end
end
