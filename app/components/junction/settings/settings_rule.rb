# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # Separates one section of a settings pane from the next.
      class SettingsRule < Base
        def view_template
          div(**attrs)
        end

        private

        def default_attrs
          { class: "border-t border-border", aria_hidden: "true" }
        end
      end
    end
  end
end
