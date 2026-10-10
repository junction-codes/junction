# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # Control for switching between different views of the same index.
      #
      # Each option is represented as a link that replaces the content of the
      # pane's turbo frame.
      class SettingsIndexSwitch < Base
        ITEM = "flex-1 rounded-md px-3 py-1 text-center text-[12.5px] " \
               "font-medium text-text-tertiary hover:text-foreground"

        CURRENT = "bg-surface shadow text-foreground"

        # Initializes the component.
        #
        # @param items [Array<Hash>] VIews available to switch between.
        # @option items [String] :label Human-readable name of the view.
        # @option items [String] :href URL to navigate to when the view is
        #   selected.
        # @option items [Boolean] :current Whether or not this view is currently
        #   active.
        # @param frame [String] The turbo frame each link replaces.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(items:, frame: nil, **user_attrs)
          @items = items
          @frame = frame

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            @items.each do |item|
              current = item[:current]

              a(href: item.fetch(:href), data: { turbo_frame: @frame },
                aria_current: ("page" if current),
                class: [ ITEM, (CURRENT if current) ].compact.join(" ")) do
                plain item.fetch(:label)
              end
            end
          end
        end

        private

        def default_attrs
          { class: "flex items-center gap-1 rounded-lg bg-background p-1" }
        end
      end
    end
  end
end
