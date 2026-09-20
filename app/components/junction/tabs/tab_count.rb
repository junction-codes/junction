# frozen_string_literal: true

module Junction
  module Components
    module Tabs
      # How many items are behind a tab, as a pill beside its label.
      #
      # A pill rather than more text. At label size and weight the number reads
      # as part of the label (e.g. "Dependencies 12"). Zero is show as well, as
      # its still a representation of the tab's content.
      #
      # @example
      #   TabCount(value: 12)
      class TabCount < Base
        # Initializes the component.
        #
        # @param value [Integer] The count.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(value:, **user_attrs)
          @value = value

          super(**user_attrs)
        end

        def view_template
          span(**attrs) { @value.to_s }
        end

        private

        def default_attrs
          # The subtle fill alone is a few percent off the page background,
          # so the pill needs the border to read as one.
          { class: "ml-2 inline-flex items-center justify-center rounded-full " \
                   "border border-border bg-subtle px-1.5 min-w-5 h-[18px] " \
                   "text-[11px] font-medium tabular-nums text-text-tertiary" }
        end
      end
    end
  end
end
