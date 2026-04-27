# frozen_string_literal: true

module Junction
  module Views
    module Plugins
      # Index view for installed plugins.
      class Index < Views::Base
        # Initializes the view.
        #
        # @param core_plugins [Array<Junction::ApplicationPlugin>] Plugins built
        #   into the core Junction Engine.
        # @param external_plugins [Array<Junction::ApplicationPlugin>] Plugins
        #   built as external gems and mounted in the host application.-
        # @param breadcrumbs [Array<Hash>] Breadcrumb trail items.
        def initialize(core_plugins:, external_plugins:, breadcrumbs: [])
          @core_plugins = core_plugins
          @external_plugins = external_plugins
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs: @breadcrumbs) do
            div(class: "px-6 py-3 space-y-8") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                t(".title")
              end

              render_section(
                title: t(".core_plugins"),
                plugins: @core_plugins
              )

              render_section(
                title: t(".external_plugins"),
                plugins: @external_plugins,
                empty_message: t(".empty_plugins")
              )
            end
          end
        end

        private

        # Renders a section of plugins.
        #
        # @param title [String] Title of the section.
        # @param plugins [Array<Junction::ApplicationPlugin>] Plugins to display.
        # @param empty_message [String] Empty message to display if there are no
        #   plugins.
        def render_section(title:, plugins:, empty_message: "")
          section(class: "space-y-4") do
            h3(class: "text-lg font-medium text-gray-800 dark:text-white") { title }

            if plugins.empty? && empty_message
              p(class: "text-sm text-gray-500 dark:text-gray-400") { empty_message }
              next
            end

            ul(class: "space-y-3") do
              plugins.each do |plugin|
                li(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-4") do
                  div(class: "flex items-start gap-3") do
                    icon(plugin.icon, class: "h-5 w-5 mt-0.5 text-gray-500")
                    div(class: "space-y-1") do
                      p(class: "text-sm font-medium text-gray-900 dark:text-white") do
                        plugin.title
                      end

                      p(class: "text-sm text-gray-500 dark:text-gray-400") do
                        plugin.description.presence || t(".empty_description")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
