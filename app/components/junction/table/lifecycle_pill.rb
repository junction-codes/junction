# frozen_string_literal: true

module Junction
  module Components
    module Table
      # An entity's lifecycle, as a pill with a status dot.
      #
      # The dot carries the meaning as position and shape, not color alone, so
      # the three states stay distinguishable without relying on hue.
      class LifecyclePill < Base
        # Lifecycle to status mapping for known lifecycles.
        DEFAULT_STATUSES = {
          "production" => "success",
          "experimental" => "warning",
          "deprecated" => "alert"
        }.freeze

        # Pill, dot class tuples for the different variants.
        STYLES = {
          "success" => [ "bg-success-subtle text-success", "bg-success-dot" ],
          "warning" => [ "bg-warning-subtle text-warning", "bg-warning-dot" ],
          "alert" => [ "bg-alert-subtle text-alert", "bg-alert-dot" ],
          "info" => [ "bg-info-subtle text-info", "bg-info-dot" ],
          "neutral" => [ "bg-subtle text-text-body", "bg-line-strong" ]
        }.freeze

        # Initializes a new component.
        #
        # @param lifecycle [String] The entity's lifecycle.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(lifecycle:, **user_attrs)
          @lifecycle = lifecycle.presence

          super(**user_attrs)
        end

        def view_template
          return if @lifecycle.nil?

          pill, dot = STYLES.fetch(status)

          span(class: "inline-flex items-center gap-2 rounded-full px-2 " \
                      "py-0.5 text-[11.5px] font-medium #{pill}",
               data: { lifecycle: @lifecycle }, **attrs) do
            span(class: "w-1.5 h-1.5 rounded-full shrink-0 #{dot}")
            plain label
          end
        end

        private

        # Status that a lifecycle corresponds to.
        #
        # If no mapping is found, the status falls back to "neutral".
        #
        # @return [String] A key of {STYLES}.
        def status
          named = option[:status].presence || DEFAULT_STATUSES[@lifecycle]

          STYLES.key?(named) ? named : "neutral"
        end

        # Human readable name of the lifecycle.
        #
        # @return [String] The label.
        def label
          option[:name] || @lifecycle.humanize
        end

        # The catalog option backing this lifecycle, if there is one.
        #
        # @return [Hash] The option's attributes.
        def option
          @option ||= Junction::CatalogOptions.lifecycles[@lifecycle] || {}
        end
      end
    end
  end
end
