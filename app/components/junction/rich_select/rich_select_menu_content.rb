# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders the dropdown menu content for rich select menus.
      class RichSelectMenuContent < Base
        # Initializes a new component.
        #
        # @param content_id [String] DOM id of the select content element.
        # @param current_value [String] Current selected value.
        # @param option_set [RichSelectOptionSet] Option set containing options.
        # @param default_icon [String] Default icon for options.
        # @param allow_create [Boolean] Whether create-new UI is enabled.
        # @param known_label [String] Label for known options group.
        # @param other_label [String] Label for other options group.
        # @param search_placeholder [String] Placeholder for search input.
        # @param no_results_text [String] Text shown when no results are found.
        # @param blank_label [String] Label for blank option.
        # @param blank_description [String] Description for blank option.
        # @param create_action [Hash] Configuration for create-new action.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(content_id:, current_value:, option_set:, default_icon:,
                       allow_create:, known_label:, other_label:,
                       search_placeholder:, no_results_text:, blank_label:,
                       blank_description:, create_action:, **user_attrs)
          @content_id = content_id
          @current_value = current_value
          @option_set = option_set
          @default_icon = default_icon
          @allow_create = allow_create
          @known_label = known_label
          @other_label = other_label
          @search_placeholder = search_placeholder
          @no_results_text = no_results_text
          @blank_label = blank_label
          @blank_description = blank_description
          @create_action = create_action

          super(**user_attrs)
        end

        def view_template
          Select::SelectContent(id: @content_id) do |content|
            render RichSelectSearchInput.new(placeholder: @search_placeholder)

            content.item(value: "", selected: @current_value.blank?, data_kind: "blank") do
              render RichSelectOptionContent.new(
                icon: @default_icon,
                name: @blank_label,
                description: @blank_description,
                description_italic: true
              )
            end

            render RichSelectOptionGroup.new(
              label: @known_label,
              ids: @option_set.known_ids,
              selected_value: @current_value,
              option_set: @option_set,
              default_icon: @default_icon
            )
            render RichSelectOtherOptionGroup.new(
              label: @other_label,
              ids: @option_set.other_ids,
              selected_value: @current_value,
              option_set: @option_set,
              default_icon: @default_icon,
              allow_create: @allow_create,
              create_action: @create_action
            )

            p(
              class: "hidden px-2 py-1.5 text-sm text-gray-500 dark:text-gray-400",
              data_ruby_ui__select_target: "emptyState"
            ) { @no_results_text }
          end
        end
      end
    end
  end
end
