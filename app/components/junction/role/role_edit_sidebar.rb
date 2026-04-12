# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Sidebar with additional actions when editing a role.
      class RoleEditSidebar < Base
        # Initialize a new component.
        #
        # @param role [Junction::Role] The role being edited.
        # @param can_destroy [Boolean] Whether the role can be destroyed.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(role:, can_destroy: true, **user_attrs)
          @role = role
          @can_destroy = can_destroy

          super(**user_attrs)
        end

        def view_template
          # Metadata section.
          Card(**attrs) do |card|
            card.header { card.title { t(".metadata") } }

            card.content do
              dl(class: "divide-y divide-gray-200 dark:divide-gray-700") do
                metadata_row(@role.class.human_attribute_name(:created_at),
                             @role.created_at.strftime("%b %d, %Y"))
                metadata_row(@role.class.human_attribute_name(:updated_at),
                             @role.updated_at.strftime("%b %d, %Y"))
              end
            end
          end

          # Danger zone for destructive actions (only when allowed and not a
          # system role).
          if @can_destroy && !@role.system?
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
                    content.header do |header|
                      header.title { t(".delete_confirm_title") }
                    end

                    content.body do
                      t(".delete_confirm_body")
                    end

                    content.footer do
                      Link(data: { action: "click->ruby-ui--dialog#dismiss" }) { t(".cancel") }
                      Link(variant: :destructive, href: role_path(@role), data_turbo_method: :delete) do
                        t(".confirm_delete")
                      end
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
