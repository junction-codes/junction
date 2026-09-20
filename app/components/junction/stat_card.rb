# frozen_string_literal: true

module Junction
  module Components
    # A single count with a label and an icon.
    #
    # @example
    #   StatCard(title: "Total Systems", value: 12, icon: "network")
    class StatCard < Base
      # Value and icon classes per status. `critical` and `danger` share the
      # alert palette, which is the only one the design gives either.
      STATUSES = {
        default: [ "text-foreground", "bg-subtle text-text-body" ],
        healthy: [ "text-success", "bg-success-subtle text-success" ],
        warning: [ "text-warning", "bg-warning-subtle text-warning" ],
        critical: [ "text-alert", "bg-alert-subtle text-alert" ],
        danger: [ "text-alert", "bg-alert-subtle text-alert" ]
      }.freeze

      # Initializes the component.
      #
      # @param title [String] Card title.
      # @param value [Integer, String] The value of the statistic.
      # @param icon [String] Icon name.
      # @param status [Symbol] One of {STATUSES}.
      def initialize(title:, value:, icon:, status: :default)
        @title = title
        @value = value
        @icon = icon
        @value_classes, @icon_classes = STATUSES.fetch(status)

        super()
      end

      def view_template
        div(class: "rounded-xl border border-border bg-surface p-5 " \
                   "flex items-start justify-between gap-4") do
          div(class: "min-w-0") do
            p(class: "text-[12.5px] font-medium text-muted-foreground") { @title }
            p(class: "mt-1 text-[24px] font-semibold tabular-nums " \
                     "#{@value_classes}") { @value.to_s }
          end

          div(class: "shrink-0 rounded-lg p-2 #{@icon_classes}") do
            icon(@icon, fallback: Junction::Kind::DEFAULT_ICON, class: "w-5 h-5")
          end
        end
      end
    end
  end
end
