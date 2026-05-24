# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders the create-new-option action row for rich select menus.
      class RichSelectCreateAction < Base
        ICON_WRAPPER_CLASS = "h-6 w-6 rounded-md bg-gray-200 " \
          "dark:bg-gray-700 flex items-center justify-center flex-shrink-0"

        # Initializes a new component.
        #
        # @param default_label [String] Label shown before any text is entered.
        # @param default_description [String] Hint shown before text is entered.
        # @param selected_description [String] Description shown after selection.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(default_label:, default_description:, selected_description:,
                       **user_attrs)
          @default_label = default_label
          @default_description = default_description
          @selected_description = selected_description

          super(**user_attrs)
        end

        def view_template
          button(**attrs) do
            div(class: "flex items-start text-left") do
              div(class: "mr-2 h-4 w-4 flex-none")

              div(class: "flex items-center space-x-4",
                  data_ruby_ui__select_target: "itemContent") do
                div(class: ICON_WRAPPER_CLASS) do
                  icon("plus", class: "h-6 w-6 text-gray-500")
                end

                div do
                  div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                    span(data_create_action_label: true) { @default_label }
                  end

                  div(class: "text-sm text-gray-500 dark:text-gray-400",
                      data_create_action_description: true) do
                    @default_description
                  end
                end
              end
            end
          end
        end

        private

        def default_attrs
          {
            type: "button",
            class: "w-full text-left item group relative cursor-pointer " \
              "select-none items-center rounded-sm px-2 py-1.5 text-sm " \
              "outline-none transition-colors hover:bg-accent " \
              "hover:text-accent-foreground focus:bg-accent " \
              "focus:text-accent-foreground",
            data_kind: "create-action",
            data: {
              default_label: @default_label,
              default_description: @default_description,
              selected_description: @selected_description,
              action: "click->ruby-ui--select#createFromQuery " \
                "keydown.enter->ruby-ui--select#createFromQuery"
            }
          }
        end
      end
    end
  end
end
