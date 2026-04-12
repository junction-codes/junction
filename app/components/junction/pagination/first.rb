# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display the first page in a pagination component.
      class First < PaginationItem
        def view_template(&block)
          Tooltip do |t|
            t.trigger do
              super do
                yield if block_given?

                icon("chevrons-left", class: "h-4 w-4")
                span(class: "sr-only") { t(".first") }
              end
            end

            t.content { t(".first") }
          end
        end

        private

        def default_attrs
          defaults = super
          defaults[:aria][:label] = I18n.t("junction.components.pagination.first.first")
          defaults[:class] << "overflow-hidden relative"

          defaults
        end
      end
    end
  end
end
