# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # The panes that make up the body of a settings page.
      #
      # The left column holds one index pane ({#index}) listing what the page
      # is about. The right column holds one detail pane per item ({#detail}),
      # with only the selected item's details visible.
      #
      # The columns are rendered as a vertical tab set. All detail panes are
      # rendered up front, since they hold the target the tabs. The content for
      # individual detail panes can be lazy-loaded using a turbo frame.
      #
      # @example A page listing two annotation keys, opened on the first.
      #   page.panes(default: "tier") do |panes|
      #     panes.index do |index|
      #       index.list do |list|
      #         list.item(value: "tier", label: "tier", count: 96)
      #         list.item(value: "on-call", label: "on-call", count: 148)
      #       end
      #     end
      #
      #     panes.detail(value: "tier") { "What tier holds" }
      #     panes.detail(value: "on-call") { "What on-call holds" }
      #   end
      class SettingsPanes < Base
        # Initializes the component.
        #
        # @param default [String] The item opened when the page loads.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(default:, **user_attrs)
          @default = default

          super(**user_attrs)
        end

        def view_template(&block)
          Tabs(variant: :index, default: @default, **attrs) do |tabs|
            @tabs = tabs
            block.call(self)
          end
        end

        # The index of items rendered as vertical tabs in the left column.
        #
        # @see SettingsIndex
        def index(**options, &)
          render SettingsIndex.new(tabs: @tabs, **options, &)
        end

        # A single item's details pane in the right column.
        #
        # Only the open one is visible to the user. Other tabs are rendered and
        # hidden, so a pane holding a request of its own should lazy-load it.
        #
        # @param value [String] The item this pane belongs to, matching the
        #   index row that opens it.
        def detail(value:, &)
          @tabs.content(value:, class: "mt-0") do
            div(class: "rounded-xl border border-border bg-surface p-6", &)
          end
        end

        private

        def default_attrs
          { class: "grid grid-cols-1 xl:grid-cols-[300px_minmax(0,1fr)] " \
                   "gap-6 items-stretch" }
        end
      end
    end
  end
end
