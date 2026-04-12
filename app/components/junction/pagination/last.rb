# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display the last page in a pagination component.
      class Last < PaginationItem
        def view_template(&block)
          Tooltip do |t|
            t.trigger do
              super do
                yield if block_given?

                icon("chevrons-right", class: "h-4 w-4")
                span(class: "sr-only") { t(".last") }
              end
            end

            t.content { t(".last") }
          end
        end

        private

        def default_attrs
          defaults = super
          defaults[:aria][:label] = I18n.t("junction.components.pagination.last.last")
          defaults[:class] << "overflow-hidden relative"

          defaults
        end
      end
    end
  end
end
