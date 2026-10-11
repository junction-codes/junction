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
        include Phlex::Rails::Helpers::TurboFrameTag

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
        # hidden, so passing `src` loads the pane's contents on demand rather
        # than building every pane up front.
        #
        # @param value [String] The item this pane belongs to, matching the
        #   index row that opens it.
        # @param src [String] Path the pane's contents are loaded from.
        # @param frame [String] The frame's id, when it differs from the item.
        def detail(value:, src: nil, frame: nil, &)
          @tabs.content(value:, class: "mt-0") do
            next lazy_pane(frame || value, src) if src

            div(class: "rounded-xl border border-border bg-surface p-6", &)
          end
        end

        private

        # Renders the frame a pane's contents arrive in.
        #
        # @param id [String] The frame's id, which the response must match.
        # @param src [String] Path the contents are loaded from.
        def lazy_pane(id, src)
          turbo_frame_tag(id, src:, target: "_top", loading: :lazy) do
            Skeleton(class: "h-20")
          end
        end

        def default_attrs
          { class: "grid grid-cols-1 xl:grid-cols-[300px_minmax(0,1fr)] " \
                   "gap-6 items-stretch" }
        end
      end
    end
  end
end
