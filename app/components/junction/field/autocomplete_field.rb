# frozen_string_literal: true

module Junction
  module Components
    # An autocomplete search field.
    #
    # The component must be placed inside an element that carries
    # `data-controller="autocomplete"` and
    # `data-autocomplete-search-url-value="<url>"`. The form's submit button
    # (rendered by the caller) should also carry
    # `data-autocomplete-target="submit"`.
    #
    # @example
    #   form_with(url: create_path, method: :post,
    #             data: { controller: "autocomplete",
    #                     autocomplete_search_url_value: search_path }) do
    #     AutocompleteField(
    #       label:             t(".search_label"),
    #       placeholder:       t(".search_placeholder"),
    #       hidden_field_name: "dependency[target]",
    #       frame_id:          "dependency-search-results"
    #     )
    #     Button(type: "submit", data: { autocomplete_target: "submit" },
    #            disabled: true) { "Add" }
    #   end
    class AutocompleteField < Base
      # Initialize a new component.
      #
      # @param label [String] Text for the visible label element.
      # @param placeholder [String] Placeholder text for the search input.
      # @param hidden_field_name [String] The `name` attribute for the hidden
      #   field that stores the selected value.
      # @param frame_id [String] Turbo Frame ID used for the results list. Must
      #   match the `turbo_frame_tag` ID in the search response view.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(label:, placeholder:, hidden_field_name:, frame_id:,
                     **user_attrs)
        @label = label
        @placeholder = placeholder
        @hidden_field_name = hidden_field_name
        @frame_id = frame_id
        @input_id = "#{frame_id}-input"

        super(**user_attrs)
      end

      def view_template
        div(**attrs) do
          label(
            for: @input_id,
            class: "block text-sm font-medium leading-6 text-gray-900 dark:text-white mb-1"
          ) { @label }

          div(class: "relative") do
            input(
              id: @input_id,
              type: "text",
              autocomplete: "off",
              placeholder: @placeholder,
              data: {
                autocomplete_target: "input",
                action: "input->autocomplete#search " \
                        "keydown.down->autocomplete#navigate " \
                        "keydown.escape->autocomplete#clearResults"
              },
              class: "block w-full rounded-md border-0 px-3 py-1.5 pr-8 text-gray-900 " \
                     "shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 " \
                     "focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 " \
                     "dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:focus:ring-blue-500"
            )

            button(
              type: "button",
              class: "absolute inset-y-0 right-0 hidden items-center pr-2 " \
                     "text-gray-400 hover:text-gray-600 dark:hover:text-gray-300",
              data: {
                autocomplete_target: "clearButton",
                action: "click->autocomplete#clear"
              }
            ) do
              icon("x", class: "w-4 h-4")
            end
          end

          input(
            type: "hidden",
            name: @hidden_field_name,
            data: { autocomplete_target: "targetValue" }
          )

          turbo_frame_tag @frame_id,
            class: "block mt-1",
            data: { autocomplete_target: "results" }
        end
      end

      private

      def default_attrs
        {
          class: "space-y-1"
        }
      end
    end
  end
end
