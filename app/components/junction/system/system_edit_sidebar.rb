# frozen_string_literal: true

module Junction
  module Components
    module System
      class SystemEditSidebar < Base
        def initialize(system:, can_destroy: true)
          @system = system
          @can_destroy = can_destroy
        end

        def view_template
          # Metadata section.
          Card do |card|
            card.header { card.title { t(".metadata") } }
            card.content do
              dl(class: "divide-y divide-gray-200 dark:divide-gray-700") do
                metadata_row(@system.class.human_attribute_name(:created_at),
                             @system.created_at.strftime("%b %d, %Y"))
                metadata_row(@system.class.human_attribute_name(:updated_at),
                             @system.updated_at.strftime("%b %d, %Y"))
              end
            end
          end

          # Danger zone for destructive actions.
          if @can_destroy
            Card(class: "border-red-500/50 dark:border-red-500/30") do |card|
              card.header do
                card.title(class: "text-red-700 dark:text-red-400") { t(".danger_zone") }
              end

              card.content(class: "space-y-4") do
                p(class: "text-sm text-gray-600 dark:text-gray-400") { t(".danger_zone_warning") }

                Dialog do |dialog|
                  dialog.trigger do
                    Button(variant: :destructive, class: "w-full justify-center") do
                      icon("trash", class: "w-4 h-4 mr-2")
                      plain t(".delete")
                    end
                  end

                  dialog.content do |content|
                    content.header { |h| h.title { t(".delete_confirm_title") } }
                    content.body { t(".delete_confirm_body") }
                    content.footer do
                      Link(data: { action: "click->ruby-ui--dialog#dismiss" }) { t(".cancel") }
                      Link(variant: :destructive, href: junction_catalog_path(@system), data_turbo_method: :delete) { t(".confirm_delete") }
                    end
                  end
                end
              end
            end
          end
        end

        private

        def metadata_row(label, value)
          div(class: "py-3 flex justify-between text-sm") do
            dt(class: "font-medium text-gray-600 dark:text-gray-400") { label }
            dd(class: "text-gray-900 dark:text-white") { value }
          end
        end
      end
    end
  end
end
