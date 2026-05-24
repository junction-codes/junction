# frozen_string_literal: true

module Junction
  module Components
    module Select
      # Renders a grouped section of select options.
      class Group < Base
        LABEL_CLASS = "px-2 pt-2 pb-1 text-xs font-semibold uppercase " \
          "tracking-wide text-gray-500 dark:text-gray-400"

        # Initializes a new component.
        #
        # @param label [String] Optional heading rendered above group items.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(label: nil, **user_attrs)
          @label = label
          super(**user_attrs)
        end

        def view_template(&block)
          div(**attrs) do
            label(@label) if @label.present?

            if block&.arity == 1
              block.call(self)
            else
              block&.call
            end
          end
        end

        # Renders the section heading for the group.
        #
        # @param text [String] Text for the heading.
        def label(text)
          p(class: LABEL_CLASS) { plain text }
        end

        def item(...)
          render SelectItem.new(...)
        end

        def link(...)
          render Link.new(...)
        end

        private

        def default_attrs
          return {} unless @label.present?

          { role: "group", aria: { label: @label } }
        end
      end
    end
  end
end
