# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display the next page in a pagination component.
      class Next < PaginationItem
        def view_template(&block)
          Tooltip do |t|
            t.trigger do
              super do
                yield if block_given?

                icon("chevron-right", class: "h-4 w-4")
                span(class: "sr-only") { t("components.pagination.next") }
              end
            end

            t.content { t("components.pagination.next") }
          end
        end

        private

        def default_attrs
          defaults = super
          defaults[:aria][:label] = I18n.t("components.pagination.next")
          defaults[:class] << "overflow-hidden relative"

          defaults
        end
      end
    end
  end
end
