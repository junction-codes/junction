# frozen_string_literal: true

module Junction
  module Components
    module Pagination
      # UI component to display an ellipsis in a pagination component.
      #
      # @todo Should we just use a plain ellipsis character instead of an icon?
      class Ellipsis < Base
        def view_template(&block)
          Tooltip do |t|
            t.trigger do
              li do
                span(**attrs) do
                  span { "…" }
                  span(class: "sr-only") { t(".more") }
                end
              end
            end

            t.content { t(".more") }
          end
        end

        private

        def default_attrs
          {
            aria: {
              disabled: true,
              hidden: true,
              label: I18n.t("junction.components.pagination.ellipsis.more")
            },
            class: [
              Link.new(variant: :disabled).attrs[:class],
              "overflow-hidden relative"
            ]
          }
        end
      end
    end
  end
end
