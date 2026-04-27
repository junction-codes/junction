# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      # Renders the application settings menu in the sidebar.
      class SettingsMenu < Base
        TRIGGER_CLASSES = "w-full justify-start px-3 py-2 text-gray-700 dark:text-gray-300"

        # Initializes a new component.
        #
        # @param items [Array<Hash>] The items to display in the menu.
        # @param title [String] The title of the menu.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(items:, title:, **user_attrs)
          @items = items
          @title = title

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            DropdownMenu(options: { placement: "right-start", strategy: "fixed" }) do |menu|
              menu.trigger(class: "w-full") do |trigger|
                trigger.button(variant: :ghost, class: TRIGGER_CLASSES) do
                  span(class: "flex-shrink-0") { icon("wrench", class: "w-6 h-6") }
                  span(data_sidebar_target: "linkText", class: "ml-4 whitespace-nowrap") { @title }
                end
              end

              menu.content do |content|
                content.label { @title }
                content.separator

                @items.each do |item|
                  content.item(
                    href: item[:disabled] ? "#" : item[:href],
                    data_disabled: item[:disabled]
                  ) do
                    icon(item[:icon], class: "w-4 h-4 mr-2")
                    plain item[:title]
                  end
                end
              end
            end
          end
        end

        private

        def default_attrs
          {
            class: "mt-auto px-2 py-4 border-t border-gray-200 dark:border-gray-700"
          }
        end
      end
    end
  end
end
