# frozen_string_literal: true

module Junction
  # Access control policy for plugins.
  class PluginsPolicy < Junction::ApplicationPolicy
    def context
      "plugins"
    end
  end
end
