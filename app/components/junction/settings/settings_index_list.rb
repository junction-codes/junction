# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # The list of items for a settings index pane.
      #
      # Each row is rendered as a tab that triggers a corresponding detail pane.
      # Optionally, items can be grouped.
      class SettingsIndexList < Base
        # Initializes the component.
        #
        # @param tabs [Tabs::Tabs] The tab set both panes belong to.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(tabs:, **user_attrs)
          @tabs = tabs

          super(**user_attrs)
        end

        def view_template(&block)
          @tabs.list(**attrs) do |list|
            @list = list
            block.call(self)
          end
        end

        # Header for a group of items that are rendered below it.
        #
        # @param label [String] Group label.
        # @param marker [Boolean] Whether or not to add the unclaimed marker.
        def group(label, marker: false, &)
          div(class: "pt-2 first:pt-0", data: { settings_group: "" }) do
            div(class: "px-2 pb-1 flex items-center gap-1.5 text-[11px] " \
                       "font-semibold uppercase tracking-wide " \
                       "text-text-tertiary") do
              span(class: "truncate") { label }
              unclaimed_dot if marker
            end

            yield_rows(&)
          end
        end

        # A single item in the list.
        #
        # @param value [String] Value of the item, used to link it to its detail
        #   pane.
        # @param label [String] Human-readable name of the item.
        # @param sublabel [String] Machine-readable name of the item, if it
        #   differs from the human-readable name.
        # @param count [Integer] Number of records associated with the item.
        # @param marker [Boolean] Whether or not to add the unclaimed marker.
        # @param icon [String] Optional icon to display at the start of the row.
        # @param icon_class [String] What to paint it, such as a kind's tint.
        def item(value:, label:, sublabel: nil, count: nil, marker: false,
                 icon: nil, icon_class: nil)
          @list.trigger(value:, class: "group w-full") do
            span(class: "min-w-0 flex items-center gap-2") do
              unclaimed_dot if marker
              row_icon(icon, icon_class)

              span(class: "min-w-0 flex flex-col items-start") do
                span(class: "truncate max-w-full") { label }

                if sublabel
                  span(class: "truncate max-w-full font-mono text-[11px] " \
                              "font-normal text-text-tertiary " \
                              "group-data-[state=active]:text-text-body") do
                    sublabel
                  end
                end
              end
            end

            if count
              span(class: "shrink-0 tabular-nums text-[11.5px] " \
                          "text-text-tertiary " \
                          "group-data-[state=active]:text-text-body") do
                count.to_s
              end
            end
          end
        end

        private

        def default_attrs
          { class: "flex flex-col items-stretch gap-0.5" }
        end

        # Renders the icon leading a row if one has been defined.
        #
        # @param name [String] The icon's name.
        # @param classes [String] What to paint it, such as a kind's tint.
        def row_icon(name, classes)
          return if name.blank?

          icon(name, fallback: Junction::Kind::DEFAULT_ICON,
               class: "shrink-0 w-4 h-4 #{classes || 'text-text-tertiary'}")
        end

        # Renders the unclaimed marker for an item.
        #
        # Used to indicated items that exist in the catalog data, but haven't
        # been defined by a plugin or other configuration.
        def unclaimed_dot
          span(class: "shrink-0 w-[5px] h-[5px] rounded-full bg-warning",
               aria_hidden: "true")
        end

        # Rows of a group sit in their own element so the group heading is not
        # one of them.
        def yield_rows(&block)
          div(class: "flex flex-col items-stretch gap-0.5") { block.call(self) }
        end
      end
    end
  end
end
