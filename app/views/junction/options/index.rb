# frozen_string_literal: true

module Junction
  module Views
    module Options
      # Index view for catalog options.
      class Index < Views::Base
        # Initializes the view.
        #
        # @param breadcrumbs [Array<Hash>] Breadcrumb trail items.
        # @param fields [Array<Hash>] Known and observed option breakdowns.
        def initialize(breadcrumbs: [], fields: [])
          @breadcrumbs = breadcrumbs
          @fields = fields
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs: @breadcrumbs) do
            div(class: "px-6 py-3 space-y-6") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                t(".title")
              end

              p(class: "text-sm text-gray-500 dark:text-gray-400") do
                t(".description")
              end

              if @fields.empty?
                p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty") }
                next
              end

              Tabs(default: @fields.first.fetch(:id), class: "grid grid-cols-1 lg:grid-cols-4 gap-6 items-start") do |tabs|
                tabs.list(class: "flex h-auto flex-col w-full items-stretch rounded-lg bg-muted p-2") do |list|
                  @fields.each do |field|
                    list.trigger(value: field.fetch(:id), class: "w-full justify-between px-3 py-2") do
                      span { field.fetch(:label) }
                      Badge(variant: :secondary, size: :sm) { field.fetch(:total_count) }
                    end
                  end
                end

                div(class: "lg:col-span-3") do
                  @fields.each do |field|
                    tabs.content(value: field.fetch(:id), class: "mt-0") do
                      render_field(field)
                    end
                  end
                end
              end
            end
          end
        end

        private

        def render_field(field)
          section(class: "space-y-6") do
            div(class: "space-y-1") do
              h3(class: "text-lg font-semibold text-gray-900 dark:text-gray-100") do
                field.fetch(:label)
              end
              p(class: "text-sm text-gray-500 dark:text-gray-400") do
                t(".records_total", count: field.fetch(:total_count))
              end
            end

            render_charts(field)
            render_known_table(field)
            render_other_table(field)
          end
        end

        def render_charts(field)
          div(class: "grid grid-cols-1 xl:grid-cols-2 gap-4") do
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-3") do
              h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
                t(".known_vs_other")
              end
              pie_chart field.dig(:charts, :known_vs_other), height: "280px"
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-3") do
              h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
                t(".value_breakdown")
              end
              bar_chart field.dig(:charts, :value_breakdown),
                        height: "280px",
                        library: { indexAxis: "y" }
            end
          end
        end

        def render_known_table(field)
          section(class: "space-y-3") do
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              t(".known")
            end

            if field.fetch(:known).empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty_known") }
              next
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              Table do |table|
                table.header do |header|
                  header.row do |row|
                    row.head { t(".option_value") }
                    row.head { t(".option_label") }
                    row.head { t(".option_description") }
                    row.head(class: "text-right") { t(".records") }
                  end
                end

                table.body do |body|
                  field.fetch(:known).each do |option|
                    body.row do |row|
                      row.cell(class: "font-mono text-xs") { option.fetch(:value) }
                      row.cell do
                        div(class: "inline-flex items-center gap-2") do
                          icon(option.fetch(:icon), class: "h-4 w-4 text-gray-500") if option[:icon].present?
                          span { option.fetch(:name) }
                        end
                      end
                      row.cell(class: "text-sm text-gray-500 dark:text-gray-400") do
                        option.fetch(:description).presence || "—"
                      end
                      row.cell(class: "text-right") { option.fetch(:count) }
                    end
                  end
                end
              end
            end
          end
        end

        def render_other_table(field)
          section(class: "space-y-3") do
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              t(".other")
            end

            if field.fetch(:other).empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty_other") }
              next
            end

            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
              Table do |table|
                table.header do |header|
                  header.row do |row|
                    row.head { t(".option_value") }
                    row.head { t(".option_label") }
                    row.head(class: "text-right") { t(".records") }
                  end
                end

                table.body do |body|
                  field.fetch(:other).each do |option|
                    body.row do |row|
                      row.cell(class: "font-mono text-xs") { option.fetch(:value) }
                      row.cell { option.fetch(:name) }
                      row.cell(class: "text-right") { option.fetch(:count) }
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
