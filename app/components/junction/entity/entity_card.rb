# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Card component for displaying an entity's information.
      #
      # @example
      #   EntityCard(title: "Links", action: [ "Edit", edit_path ]) { ... }
      class EntityCard < Base
        # Padding for the two halves of a card split by a divider, keeping
        # each clear of it.
        SIDES = { start: "min-w-0 md:pr-5", end: "min-w-0 md:pl-5" }.freeze

        # Initializes the component.
        #
        # @param title [String] The card's heading.
        # @param action [Array(String, String)] Label and path for the
        #   link beside the heading, if the card has one.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(title:, action: nil, **user_attrs)
          @title = title
          @action = action

          super(**user_attrs)
        end

        def view_template(&)
          section(**attrs) do
            div(class: "flex items-baseline justify-between gap-4 mb-4") do
              h2(class: "text-[15px] font-semibold text-foreground") { @title }
              action_link
            end

            yield
          end
        end

        private

        def action_link
          return unless @action

          label, href = @action
          Link(href:, variant: :text,
               class: "text-[12.5px] font-medium text-accent-strong") { label }
        end

        def default_attrs
          { class: "rounded-xl border border-border bg-surface p-5" }
        end
      end
    end
  end
end
