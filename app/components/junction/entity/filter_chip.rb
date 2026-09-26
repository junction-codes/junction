# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # A single active filter on the bar above a catalog listing.
      #
      # Given a block, the block is the chip's content.
      class FilterChip < Base
        SHAPE = "inline-flex items-center gap-1.5 h-[30px] px-3 rounded-lg " \
                "text-[12.5px] font-medium whitespace-nowrap"

        # How a chip reads: filtering, offering its values, or standing by.
        STYLES = {
          applied: "#{SHAPE} bg-accent text-accent-foreground rounded-r-none pr-2",
          waiting: "#{SHAPE} bg-surface border border-border text-text-body " \
                   "hover:bg-subtle",
          quiet: "#{SHAPE} bg-subtle text-text-tertiary hover:text-foreground"
        }.freeze

        # Initializes the component.
        #
        # @param text [String] What the chip reads, when it has no block.
        # @param remove [String] Where dropping the filter goes.
        # @param remove_label [String] What dropping it is called, for
        #   screen readers.
        def initialize(text: nil, remove: nil, remove_label: nil)
          @text = text
          @remove = remove
          @remove_label = remove_label

          super()
        end

        def view_template(&)
          div(class: "flex items-center") do
            if block_given?
              yield
            else
              span(class: STYLES.fetch(:applied)) { @text }
            end

            remove_link
          end
        end

        private

        # The remove link on an active filter chip.
        #
        # A link of its own rather than an entry in the chip's own menu, so
        # dropping a filter takes one click.
        def remove_link
          return if @remove.nil?

          a(href: @remove, aria_label: @remove_label,
            class: "-ml-1 h-[30px] pr-2 pl-1 flex items-center rounded-r-lg " \
                   "bg-accent text-accent-muted hover:text-accent-foreground") do
            icon("x", class: "w-3.5 h-3.5")
          end
        end
      end
    end
  end
end
