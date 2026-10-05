# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # Index of items rendered as vertical tabs on a settings page.
      class SettingsIndex < Base
        # Initializes the component.
        #
        # @param tabs [Tabs::Tabs] The tab set both panes belong to.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(tabs:, **user_attrs)
          @tabs = tabs

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs, &)
        end

        # Search filter for the list of items.
        #
        # @param placeholder [String] Placeholder text for the search input.
        def filter(placeholder:)
          div(class: "relative", data: { controller: "list-filter" }) do
            icon("search", class: "absolute left-3 top-1/2 -translate-y-1/2 " \
                                  "w-[15px] h-[15px] text-text-tertiary")

            input(type: "search", placeholder:, aria_label: placeholder,
                  data: { list_filter_target: "input",
                          action: "input->list-filter#filter" },
                  class: "w-full rounded-lg border border-border bg-background " \
                         "py-2 pl-9 pr-3 text-[13px] text-foreground " \
                         "placeholder:text-text-tertiary focus:outline-none " \
                         "focus:ring-2 focus:ring-ring")
          end
        end

        def list(**options, &)
          render SettingsIndexList.new(tabs: @tabs, **options, &)
        end

        # Footnote displayed at the bottom of the index.
        def footnote(&)
          div(class: "border-t border-border pt-3 text-[11.5px] leading-4 " \
                     "text-text-tertiary space-y-1", &)
        end

        private

        def default_attrs
          { class: "rounded-xl border border-border bg-surface p-4 space-y-3" }
        end
      end
    end
  end
end
