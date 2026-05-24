# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders a grouped section of rich select options.
      class RichSelectOptionGroup < Base
        # Initializes a new component.
        #
        # @param label [String] Label for the group.
        # @param ids [Array<String>] List of option IDs to render.
        # @param selected_value [String] Current selected value.
        # @param option_set [RichSelectOptionSet] Option set containing options.
        # @param default_icon [String] Default icon for options.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(label:, ids:, selected_value:, option_set:, default_icon:,
                       **user_attrs)
          @label = label
          @ids = ids
          @selected_value = selected_value
          @option_set = option_set
          @default_icon = default_icon

          super(**user_attrs)
        end

        def view_template
          return if @ids.empty?

          Select::Group(label: @label) do |group|
            @ids.each do |id|
              option = @option_set.fetch(id)

              group.item(
                value: id,
                selected: @selected_value.present? && @selected_value == id,
                data_kind: "option",
                data_search: @option_set.search_text(id)
              ) do
                render RichSelectOptionContent.new(
                  icon: option[:icon] || @default_icon,
                  name: option[:name],
                  description: option[:description]
                )
              end
            end
          end
        end
      end
    end
  end
end
