# frozen_string_literal: true

module Junction
  module Views
    module Options
      # The catalog options settings page.
      #
      # Every field the catalog knows values for, and for each one what the
      # YAML declares against what entities actually carry.
      class Index < Views::Base
        # Where the options are declared, named on the page so it is clear
        # this is a file rather than a table.
        SOURCE_FILE = "config/catalog_options.yaml"

        # Fill color for undeclared values.
        OTHER_FILL = "bg-line-strong"

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
            SettingsPage(title: t(".title"), description: t(".description")) do |page|
              page.callout(variant: :info) { t(".configuration_note") }

              if @fields.empty?
                p(class: "text-sm text-text-tertiary") { t(".empty") }
                next
              end

              page.panes(default: @fields.first.fetch(:id)) do |panes|
                index_pane(panes)
                @fields.each { |field| detail_pane(panes, field) }
              end
            end
          end
        end

        private

        # Renders the index pane listing all known fields.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def index_pane(panes)
          panes.index do |index|
            index.list do |list|
              list.group(t(".fields")) do |group|
                @fields.each do |field|
                  group.item(value: field.fetch(:id), label: field.fetch(:label),
                             sublabel: field.fetch(:id),
                             count: field.fetch(:total_count))
                end
              end
            end

            index.footnote { span(class: "font-mono") { SOURCE_FILE } }
          end
        end

        # Renders the detail pane for a specific field.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        # @param field [Hash] The field's breakdown.
        def detail_pane(panes, field)
          panes.detail(value: field.fetch(:id)) do
            div(class: "space-y-6") do
              SettingsDetailHeader(title: field.fetch(:label), mono: false,
                                   chip: field.fetch(:id),
                                   description: summary(field))
              declared_split(field)
              known_options(field)
              undeclared_options(field)
            end
          end
        end

        # Summary for a single field.
        #
        # @param field [Hash] The field's breakdown.
        # @return [String] The summary.
        def summary(field)
          [
            t(".records_total", count: field.fetch(:total_count)),
            t(".known_values", count: field.fetch(:known).size),
            t(".undeclared_values", count: field.fetch(:other).size)
          ].join(" · ")
        end

        # Comparison of the declared and undeclared values found in the catalog.
        #
        # @param field [Hash] The field's breakdown.
        def declared_split(field)
          total = field.fetch(:total_count)
          return if total.zero?

          known = field.fetch(:known_total_count)

          other = total - known

          div(class: "space-y-2.5") do
            Meter(segments: [ { value: known },
                              { value: other, fill: OTHER_FILL } ])

            MeterLegend(
              items: [ { label: t(".known_segment", count: known) },
                       { label: t(".other_segment", count: other),
                         fill: OTHER_FILL } ],
              caption: t(".coverage", percent: Junction::Percentage.of(known, total))
            )
          end
        end

        # The values the YAML declares, in the order it declares them.
        #
        # @param field [Hash] The field to display known options for.
        def known_options(field)
          section(class: "space-y-3") do
            section_heading(t(".known"), t(".yaml_order"))

            if field.fetch(:known).empty?
              p(class: "text-sm text-text-tertiary") { t(".empty_known") }
              next
            end

            Table do |table|
              table.header do |header|
                header.row do |row|
                  row.head(class: "w-8") { span(class: "sr-only") { t(".option_icon") } }
                  row.head { t(".option_value") }
                  row.head { t(".option_label") }
                  row.head(class: "w-[200px]") { span(class: "sr-only") { t(".share") } }
                  row.head(class: "text-right") { t(".in_use") }
                end
              end

              table.body do |body|
                highest = field.fetch(:known).map { |option| option.fetch(:count) }.max.to_i
                field.fetch(:known).each { |option| known_row(body, option, highest) }
              end
            end
          end
        end

        # One row in the table of known options.
        #
        # @param body [Components::Table::TableBody] The table's body.
        # @param option [Hash] The declared option.
        # @param highest [Integer] The most-used value's count.
        def known_row(body, option, highest)
          body.row do |row|
            row.cell(class: "align-top pr-0") do
              icon(option[:icon].presence || Junction::Kind::DEFAULT_ICON,
                   class: "h-4 w-4 text-text-tertiary",
                   fallback: Junction::Kind::DEFAULT_ICON)
            end

            row.cell(class: "font-mono text-xs align-top") { option.fetch(:value) }

            row.cell do
              span { option.fetch(:name) }

              if option.fetch(:description).present?
                p(class: "text-[12px] text-text-tertiary") do
                  option.fetch(:description)
                end
              end
            end

            row.cell(class: "align-top") do
              usage_bar(option.fetch(:count), highest)
            end

            row.cell(class: "text-right tabular-nums align-top") do
              option.fetch(:count)
            end
          end
        end

        # How much of the field one value accounts for, against the most used
        # one rather than the total
        #
        # @param count [Integer] The value's count.
        # @param highest [Integer] The most-used value's count.
        def usage_bar(count, highest)
          Meter(value: count, total: highest, size: :xs)
        end

        # The values that haven't been explicitly declared.
        #
        # @param field [Hash] The field's breakdown.
        def undeclared_options(field)
          other = field.fetch(:other)
          return if other.empty?

          section(class: "space-y-3") do
            section_heading(
              t(".other"),
              [ t(".other_values_count", count: other.size),
                t(".other_records", count: field.fetch(:other_total_count)) ]
                .join("  ·  ")
            )

            Table do |table|
              table.body do |body|
                other.each do |option|
                  body.row do |row|
                    row.cell(class: "font-mono text-xs") { option.fetch(:value) }
                    row.cell(class: "text-[12px] text-text-tertiary") do
                      t(".fallback_note")
                    end
                    row.cell(class: "text-right tabular-nums") { option.fetch(:count) }
                  end
                end
              end
            end

            promote_note(field, other.first)
          end
        end

        # Renders a note explaining how to promote an undeclared value.
        #
        # @param field [Hash] The field's breakdown.
        # @param option [Hash] The first undeclared value, as the example.
        def promote_note(field, option)
          div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 items-center") do
            pre(class: "rounded-lg bg-code p-4 overflow-x-auto text-[12px] " \
                       "leading-5 font-mono text-text-body") do
              plain snippet(field, option)
            end

            p(class: "text-[12.5px] leading-5 text-text-tertiary") do
              t(".promote_note")
            end
          end
        end

        # Generates the YAML snippet for promoting an undeclared value.
        #
        # @param field [Hash] The field's breakdown.
        # @param option [Hash] The value to promote.
        # @return [String] The YAML that would declare it.
        def snippet(field, option)
          <<~YAML
            #{field.fetch(:section)}:
              #{yaml_scalar(option.fetch(:value))}:
                name: #{yaml_scalar(option.fetch(:name))}
          YAML
        end

        # A value as YAML would have to write it.
        #
        # @param value [String] The value.
        # @return [String] The value, quoted where it needs to be.
        def yaml_scalar(value)
          dumped = value.to_s.to_yaml

          return value.to_s.inspect if dumped.lines.size > 1

          dumped.delete_prefix("---").strip
        end

        # Renders the heading for a single section.
        #
        # @param title [String] What the section is.
        # @param hint [String] What is worth knowing about it.
        def section_heading(title, hint)
          div(class: "flex items-baseline justify-between gap-4") do
            h3(class: "text-[14px] font-semibold text-foreground") { title }
            span(class: "text-[11.5px] text-text-tertiary") { hint }
          end
        end

        # Calculates the percentage share of a count against a total.
        #
      end
    end
  end
end
