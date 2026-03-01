# frozen_string_literal: true

module Junction
  module Components
    class UserEditSidebar < Base
      def initialize(user:, can_destroy: true)
        @user = user
        @can_destroy = can_destroy
      end

      def view_template
        # Metadata section.
        render Components::Card.new do |card|
          card.header { card.title { "Metadata" } }
          card.content do
            dl(class: "divide-y divide-gray-200 dark:divide-gray-700") do
              metadata_row("Created At", @user.created_at.strftime("%b %d, %Y"))
              metadata_row("Last Updated", @user.updated_at.strftime("%b %d, %Y"))
            end
          end
        end

        # Danger zone for destructive actions.
        if @can_destroy
          render Components::Card.new(class: "border-red-500/50 dark:border-red-500/30") do |card|
            card.header do
              card.title(class: "text-red-700 dark:text-red-400") { "Danger Zone" }
            end

            card.content(class: "space-y-4") do
              p(class: "text-sm text-gray-600 dark:text-gray-400") { "These actions are irreversible. Please be certain." }

              render Dialog do |dialog|
                dialog.trigger do
                  render Button.new(variant: :destructive, class: "w-full justify-center") do
                    icon("trash", class: "w-4 h-4 mr-2")
                    plain "Delete User"
                  end
                end

                dialog.content do |content|
                  content.header do |header|
                    header.title { "Are you absolutely sure?" }
                  end

                  content.body do
                    "This action cannot be undone. This will permanently remove the user and all of its associated data."
                  end

                  content.footer do
                    render Link.new(data: { action: "click->ruby-ui--dialog#dismiss" }) { "Cancel" }
                    render Link.new(variant: :destructive, href: user_path(@user), data_turbo_method: :delete) { "Confirm Delete" }
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
