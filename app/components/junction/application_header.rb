# frozen_string_literal: true

module Junction
  module Components
    # The bar across the top of the content column.
    class ApplicationHeader < Base
      # Initializes a new component.
      #
      # @param breadcrumbs [Array<Hash>] Breadcrumb items for the page.
      # @param user_attrs [Hash] Additional HTML attributes.
      def initialize(breadcrumbs: [], **user_attrs)
        @breadcrumbs = breadcrumbs

        super(**user_attrs)
      end

      def view_template
        header(**attrs) do
          div(class: "flex items-center gap-4 min-w-0") do
            collapse_toggle
            Trail(items: @breadcrumbs) if @breadcrumbs.present?
          end

          NewEntityMenu()
        end
      end

      private

      def collapse_toggle
        button(type: "button",
               data_action: "click->sidebar#toggle",
               data_sidebar_target: "toggle",
               aria_controls: "junction-sidebar",
               aria_expanded: "true",
               aria_label: t(".toggle_sidebar"),
               class: "shrink-0 cursor-pointer text-muted-foreground " \
                      "hover:text-foreground focus-visible:outline-none " \
                      "focus-visible:ring-1 focus-visible:ring-ring " \
                      "rounded-md p-0.5") do
          icon("panel-left", class: "w-[18px] h-[18px]")
        end
      end

      def default_attrs
        {
          class: "h-15 shrink-0 flex items-center justify-between gap-4 " \
                 "px-5 bg-surface border-b border-border"
        }
      end
    end
  end
end
