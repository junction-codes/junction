# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Renders the "Other" option section and optional create action.
      class RichSelectOtherOptionGroup < Base
        # Initializes a new component.
        #
        # @param label [String] Label for the group.
        # @param ids [Array<String>] List of option IDs to render.
        # @param selected_value [String] Current selected value.
        # @param option_set [RichSelectOptionSet] Option set containing options.
        # @param default_icon [String] Default icon for options.
        # @param allow_create [Boolean] Whether create-new UI is enabled.
        # @param create_action [Hash] Configuration for create-new action.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(label:, ids:, selected_value:, option_set:, default_icon:,
                       allow_create:, create_action:, **user_attrs)
          @label = label
          @ids = ids
          @selected_value = selected_value
          @option_set = option_set
          @default_icon = default_icon
          @allow_create = allow_create
          @create_action = create_action

          super(**user_attrs)
        end

        def view_template
          return if @ids.empty? && !@allow_create

          Select::Group(label: @label) do |group|
            render_create_action if @allow_create

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

        private

        def render_create_action
          render RichSelectCreateAction.new(**@create_action)
        end
      end
    end
  end
end
