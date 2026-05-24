# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Rich select component, for a more modern select experience.
      class RichSelect < Base
        # Initializes a new component.
        #
        # @param value [String] Currently selected value.
        # @param input_id [String] ID of the input element.
        # @param input_name [String] Name of the input element.
        # @param options [Hash] Selectable options keyed by stored value.
        # @param icon [String] Default icon for options.
        # @param allow_create [Boolean] Whether create-new options is enabled.
        # @param known_label [String] Label for known options group.
        # @param other_label [String] Label for other options group.
        # @param search_placeholder [String] Placeholder for autocomplete search
        #   input.
        # @param no_results_text [String] Text shown when no results are found.
        # @param blank_label [String] Label for blank option.
        # @param blank_description [String] Description for blank option.
        # @param create_action [Hash] Configuration for create-new action.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(value:, input_id:, input_name:, options: {},
                       icon: "circle-small", allow_create: true, known_label:,
                       other_label:, search_placeholder:, no_results_text:,
                       blank_label:, blank_description:, create_action:,
                       **user_attrs)
          @value = value
          @input_id = input_id
          @input_name = input_name
          @options = options
          @icon = icon
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
          Select(**attrs, data: { ruby_ui__select_allow_create_value: @allow_create.to_s }) do |select|
            select.input(value: @value, id: @input_id, name: @input_name)
            select.trigger(class: "h-auto") do |trigger|
              trigger.value(id: @input_id, class: "px-2") do
                render RichSelectTriggerValue.new(
                  value: @value,
                  option_set:,
                  default_icon: @icon,
                  blank_label: @blank_label,
                  blank_description: @blank_description
                )
              end
            end

            render RichSelectMenuContent.new(
              content_id: "#{@input_id}_content",
              current_value: @value,
              option_set:,
              default_icon: @icon,
              allow_create: @allow_create,
              known_label: @known_label,
              other_label: @other_label,
              search_placeholder: @search_placeholder,
              no_results_text: @no_results_text,
              blank_label: @blank_label,
              blank_description: @blank_description,
              create_action: @create_action
            )
          end
        end

        private

        def option_set
          @option_set ||= RichSelectOptionSet.new(@options, default_icon: @icon)
        end
      end
    end
  end
end
