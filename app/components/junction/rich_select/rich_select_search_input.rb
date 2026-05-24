# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Search input for autocomplete rich selects.
      class RichSelectSearchInput < Base
        # Initializes a new component.
        #
        # @param placeholder [String] Placeholder text for the input.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(placeholder:, **user_attrs)
          @placeholder = placeholder

          super(**user_attrs)
        end

        def view_template
          div(class: "p-2 border-b border-gray-200 dark:border-gray-700") do
            input(**attrs)
          end
        end

        private

        def default_attrs
          {
            type: "text",
            placeholder: @placeholder,
            aria: {
              label: @placeholder
            },
            class: "w-full rounded-md border border-input bg-white " \
              "dark:bg-gray-900 px-2 py-1 text-sm",
            data: {
              ruby_ui__select_target: "filterInput",
              action: "input->ruby-ui--select#filterItems " \
                "keydown.enter->ruby-ui--select#createFromQuery " \
                "keydown.esc->ruby-ui--select#handleEsc " \
                "keydown.down->ruby-ui--select#handleKeyDown " \
                "keydown.up->ruby-ui--select#handleKeyUp"
            }
          }
        end
      end
    end
  end
end
