# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders the trigger component for rich-select components.
      class RichSelectTriggerValue < Base
        # Initializes a new component.
        #
        # @param value [String] Current selected value.
        # @param option_set [RichSelectOptionSet] Option set containing options.
        # @param default_icon [String] Default icon for options.
        # @param blank_label [String] Label for the blank option.
        # @param blank_description [String] Description for the blank option.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(value:, option_set:, default_icon:, blank_label:,
                       blank_description:, **user_attrs)
          @value = value
          @option_set = option_set
          @default_icon = default_icon
          @blank_label = blank_label
          @blank_description = blank_description

          super(**user_attrs)
        end

        def view_template
          option = selected_option

          render RichSelectOptionContent.new(
            icon: option[:icon] || @default_icon,
            name: option[:name],
            description: option[:description],
            description_italic: @value.blank?,
            target: "valueContent"
          )
        end

        private

        # Returns the option data for the currently selected option, if any.
        #
        # If no value is currently select, data representing the blank option is
        # returned.
        #
        # @return [Hash] The option data.
        def selected_option
          return @option_set.fetch(@value) if @value.present?

          {
            name: @blank_label,
            description: @blank_description,
            icon: @default_icon
          }
        end
      end
    end
  end
end
