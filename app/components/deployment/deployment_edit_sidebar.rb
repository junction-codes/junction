# frozen_string_literal: true

module Components
  class DeploymentEditSidebar < Base
    def initialize(deployment:)
      @deployment = deployment
    end

    def view_template
      # Metadata section.
      render Components::Card.new do |card|
        card.header { card.title { "Metadata" } }
        card.content do
          dl(class: "divide-y divide-gray-200 dark:divide-gray-700") do
            metadata_row("Created At", @deployment.created_at.strftime("%b %d, %Y"))
            metadata_row("Last Updated", @deployment.updated_at.strftime("%b %d, %Y"))
          end
        end
      end

      # Danger zone for destructive actions.
      render Components::Card.new(class: "border-red-500/50 dark:border-red-500/30") do |card|
        card.header do
          card.title(class: "text-red-700 dark:text-red-400") { "Danger Zone" }
        end

        card.content(class: "space-y-4") do
          p(class: "text-sm text-gray-600 dark:text-gray-400") { "This action is irreversible. Please be certain." }

          render Dialog do |dialog|
            dialog.trigger do
              render Button.new(variant: :destructive, class: "w-full justify-center") do
                icon("trash", class: "w-4 h-4 mr-2")
                plain "Delete Deployment"
              end
            end

            dialog.content do |content|
              content.header { |h| h.title { "Are you absolutely sure?" } }
              content.body { "This will permanently remove the deployment." }
              content.footer do
                render Link.new(data: { action: "click->ruby-ui--dialog#dismiss" }) { "Cancel" }
                render Link.new(variant: :destructive, href: deployment_path(@deployment), data_turbo_method: :delete) { "Confirm Delete" }
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
