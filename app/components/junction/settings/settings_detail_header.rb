# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # Header for a settings detail pane.
      class SettingsDetailHeader < Base
        # Fill and dot classes for each state a badge can carry.
        STATE_STYLES = {
          success: [ "bg-success-subtle text-success", "bg-success" ],
          accent: [ "bg-accent text-accent-stronger", "bg-accent-stronger" ],
          outline: [ "bg-subtle text-text-tertiary", "bg-line-strong" ],
          secondary: [ "bg-subtle text-text-tertiary", "bg-line-strong" ]
        }.freeze

        # Initializes the component.
        #
        # @param title [String] Machine-readable name of the item being
        #   described.
        # @param subtitle [String] Human-readable name of the item.
        # @param description [String] Item description.
        # @param chip [String] Optional value to display beside the title.
        # @param badge [Hash<Symbol, String>] Optional badge for the state
        #   beside the title.
        # @option badge [String] :label Label for the badge.
        # @option badge [String] :variant Badge variant.
        # @option badge [Boolean] :dot Whether to precede the label with a
        #   status dot.
        # @param mono [Boolean] Whether the title is a machine's name for the
        #   thing, such as an annotation key, rather than a product's.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(title:, subtitle: nil, description: nil, badge: nil,
                       chip: nil, mono: true, **user_attrs)
          @title = title
          @chip = chip
          @subtitle = subtitle
          @description = description
          @badge = badge
          @mono = mono

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs) do
            div(class: "flex items-start justify-between gap-4") do
              div(class: "min-w-0") do
                div(class: "flex items-center flex-wrap gap-x-3 gap-y-2 min-w-0") do
                  h2(class: [ "text-[20px] font-semibold text-foreground truncate",
                              ("font-mono text-[17px]" if @mono) ].compact.join(" ")) do
                    @title
                  end

                  name_chip
                  state_badge
                end

                if @subtitle
                  p(class: "mt-1 text-[14px] font-medium text-foreground") do
                    @subtitle
                  end
                end
              end
            end

            if @description
              p(class: "mt-2 max-w-3xl text-[13.5px] leading-6 " \
                       "text-text-tertiary") { @description }
            end

            yield if block_given?
          end
        end

        private

        def default_attrs
          { class: "min-w-0" }
        end

        # Machine-readable name of the item, displayed beside the human-readable
        # title.
        def name_chip
          return if @chip.blank?

          span(class: "shrink-0 font-mono text-[13px] text-text-tertiary") do
            @chip
          end
        end

        # Badge for the state of the item.
        def state_badge
          return if @badge.blank?

          fill, dot = STATE_STYLES.fetch(@badge.fetch(:variant, :secondary).to_sym,
                                         STATE_STYLES.fetch(:secondary))

          span(class: "shrink-0 inline-flex items-center gap-1.5 rounded-full " \
                      "px-2.5 py-1 text-[11.5px] font-medium #{fill}") do
            span(class: "w-1.5 h-1.5 rounded-full shrink-0 #{dot}") if @badge[:dot]
            plain @badge.fetch(:label)
          end
        end
      end
    end
  end
end
