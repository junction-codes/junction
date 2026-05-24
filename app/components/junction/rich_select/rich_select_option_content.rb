# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders the content for a single rich select option.
      class RichSelectOptionContent < Base
        ICON_WRAPPER_CLASS = "h-6 w-6 rounded-md bg-gray-200 dark:bg-gray-700" \
          "flex items-center justify-center flex-shrink-0"

        # Initializes a new component.
        #
        # @param icon [String] Icon to render for the option.
        # @param name [String] Label text.
        # @param description [String, nil] Optional description.
        # @param target [String] Stimulus target for select content swaps.
        # @param description_italic [Boolean] Whether to italicize description.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(icon:, name:, description: nil, target: "itemContent",
                       description_italic: false, **user_attrs)
          @icon = icon
          @name = name
          @description = description
          @target = target
          @description_italic = description_italic

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            div(class: ICON_WRAPPER_CLASS) do
              icon(@icon, class: "h-6 w-6 text-gray-500")
            end

            div do
              div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                plain @name
              end

              if @description.present?
                div(class: description_class) { plain @description }
              end
            end
          end
        end

        private

        def default_attrs
          {
            class: "flex items-center space-x-4 text-left",
            data: {
              ruby_ui__select_target: @target
            }
          }
        end

        def description_class
          classes = "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs"
          classes += " italic" if @description_italic
          classes
        end
      end
    end
  end
end
