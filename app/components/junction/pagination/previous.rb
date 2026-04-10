# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display the previous page in a pagination component.
      class Previous < PaginationItem
        def view_template(&block)
          Tooltip do |t|
            t.trigger do
              super do
                yield if block_given?

                icon("chevron-left", class: "h-4 w-4")
                span(class: "sr-only") { t("components.pagination.previous") }
              end
            end

            t.content { t("components.pagination.previous") }
          end
        end

        private

        def default_attrs
          defaults = super
          defaults[:aria][:label] = I18n.t("components.pagination.previous")
          defaults[:class] << "overflow-hidden relative"

          defaults
        end
      end
    end
  end
end
