# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      # Groups a run of navigation rows under a heading.
      #
      # The heading is a real element rather than a decorative label. It names
      # the `role="group"` wrapping the rows, so the rail reads as three named
      # groups instead of one long list. When the rail collapses the heading
      # becomes a short rule, and the group keeps its name through
      # `aria-label`.
      class SidebarSection < Base
        # Initializes a new component.
        #
        # @param title [String] Heading for the group.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(title:, **user_attrs)
          @title = title

          super(**user_attrs)
        end

        def view_template(&)
          div(role: "group", aria_label: @title, **attrs) do
            render_heading
            div(class: "space-y-0.5", &)
          end
        end

        private

        def render_heading
          div(class: "h-4 flex items-center px-3") do
            span(data_sidebar_target: "linkText",
                 class: "text-[10.5px] font-semibold uppercase " \
                        "tracking-[0.08em] text-muted-foreground") do
              @title
            end

            # Stands in for the heading once the label is hidden, so the
            # section break survives the collapse.
            span(data_sidebar_target: "sectionRule", aria_hidden: "true",
                 class: "hidden w-6 mx-auto border-t border-border")
          end
        end

        def default_attrs
          { class: "pt-3" }
        end
      end
    end
  end
end
