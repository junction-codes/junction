# frozen_string_literal: true

module Junction
  module Components
    module Autocomplete
      # A single result item in an autocomplete search results list.
      #
      # @example
      #   ResultItem(value: item.id, name: item.name) { item.subtitle }
      class ResultItem < Base
        # Initialize a new component.
        #
        # @param value [String] Value stored in the hidden field on selection.
        # @param name [String] Display name shown as the primary label and
        #   written back to the text input on selection.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(value:, name:, **user_attrs)
          @value = value
          @name = name

          super(**user_attrs)
        end

        def view_template
          li(**attrs) do
            span(class: "text-sm font-medium text-foreground") { @name }
            span(class: "text-xs text-text-tertiary") { yield }
          end
        end

        private

        def default_attrs
          {
            role: "option",
            tabindex: "-1",
            data: {
              action: "click->autocomplete#select",
              autocomplete: {
                target: "item",
                value_param: @value,
                name_param: @name
              }
            },
            class: "flex items-center justify-between px-3 py-2 cursor-pointer " \
                   "hover:bg-accent aria-selected:bg-accent"
          }
        end
      end
    end
  end
end
