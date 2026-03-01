# frozen_string_literal: true

module Junction
  class DomainPolicy < Junction::ApplicationPolicy
    def context
      "domains"
    end
  end
end
