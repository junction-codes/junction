# frozen_string_literal: true

module Junction
  # Access control policy for catalog options.
  class OptionsPolicy < Junction::ApplicationPolicy
    def context
      "options"
    end
  end
end
