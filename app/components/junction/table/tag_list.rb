# frozen_string_literal: true

module Junction
  module Components
    module Table
      # The tags on a listing row.
      #
      # A row has room for a couple of chips, so the rest are counted rather
      # than wrapped. The overflow marker displays the additional tags on mouse
      # over.
      class TagList < Base
        VISIBLE = 2

        # Initializes a new component.
        #
        # @param tags [Array<String>] The entity's tags.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(tags:, **user_attrs)
          @tags = Array(tags)

          super(**user_attrs)
        end

        def view_template
          return empty if @tags.empty?

          div(**attrs) do
            @tags.first(VISIBLE).each { |tag| chip(tag) }
            overflow
          end
        end

        private

        # Renders the chip for a single tag.
        #
        # `overflow_title_controller` adds and removes a `title` attribute as
        # needed based on the current viewport. We don't add a tooltip here
        # because then it would always be present, even when fully visible.
        #
        # @param tag [String] The tag.
        def chip(tag)
          span(class: "px-2 py-0.5 rounded-[5px] bg-subtle text-[11px] " \
                      "font-medium text-text-body truncate min-w-0") { tag }
        end

        # Renders the overflow elements.
        def overflow
          hidden = @tags.drop(VISIBLE)
          return if hidden.empty?

          # Keep the overflow marker visible, even when the row is clipped.
          Tooltip(class: "shrink-0") do |tooltip|
            tooltip.trigger { overflow_marker(hidden.size) }
            tooltip.content { hidden.join(", ") }
          end
        end

        # Renders the overflow marker itself.
        #
        # @param count [Integer] How many tags didn't fit.
        def overflow_marker(count)
          span(tabindex: 0,
               aria_label: t(".more", count:),
               class: "text-[11px] font-medium text-muted-foreground " \
                      "rounded cursor-default focus-visible:outline-none " \
                      "focus-visible:ring-1 focus-visible:ring-ring") do
            "+#{count}"
          end
        end

        def empty
          span(class: "text-[11px] text-muted-foreground") { t(".none") }
        end

        def default_attrs
          { class: "flex items-center gap-1.5 min-w-0" }
        end
      end
    end
  end
end
