# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      # Search box at the top of the navigation rail.
      class SidebarSearch < Base
        def view_template
          div(**attrs) do
            div(data_sidebar_target: "searchBox") do
              render SearchBar.new(
                input_class: "w-full h-9 pl-9 pr-3 rounded-lg border " \
                             "border-border bg-background text-sm " \
                             "text-foreground placeholder:text-muted-foreground " \
                             "focus:outline-none focus:ring-1 focus:ring-ring"
              )
            end

            button(type: "button",
                   data_sidebar_target: "searchButton",
                   data_action: "click->sidebar#expandAndSearch",
                   aria_label: t(".expand"),
                   class: "hidden w-10 h-9 items-center justify-center " \
                          "rounded-lg border border-border bg-background " \
                          "text-muted-foreground hover:text-foreground") do
              icon("search", class: "w-4 h-4")
            end
          end
        end

        private

        def default_attrs
          { class: "px-4 pb-2" }
        end
      end
    end
  end
end
