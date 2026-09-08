# frozen_string_literal: true

module Junction
  module Components
    module ThemeToggle
      # UI component to select the user's theme.
      class ThemeToggle < Base
        # Available options, in display order. Each option is a tuple with the
        # theme name and icon.
        OPTIONS = [
          [ "light", "sun" ],
          [ "dark", "moon" ],
          [ "system", "monitor" ]
        ].freeze

        def view_template
          div(role: "radiogroup", aria_label: t(".label"), **attrs) do
            OPTIONS.each { |theme, name| option(theme, name) }
          end
        end

        private

        def option(theme, icon_name)
          button(type: "button",
                 role: "radio",
                 aria_checked: "false",
                 aria_label: t(".#{theme}"),
                 data: {
                   ruby_ui__theme_toggle_target: "option",
                   theme:,
                   action: "click->ruby-ui--theme-toggle#select"
                 },
                 class: "w-[26px] h-6 flex items-center justify-center " \
                        "rounded-md text-muted-foreground cursor-pointer " \
                        "transition-colors hover:text-foreground " \
                        "aria-checked:bg-control-thumb " \
                        "aria-checked:text-foreground aria-checked:shadow-sm") do
            icon(icon_name, class: "w-4 h-4")
          end
        end

        def default_attrs
          {
            data: {
              controller: "ruby-ui--theme-toggle",
              action: "junction:theme-changed@window->" \
                      "ruby-ui--theme-toggle#refresh"
            },
            class: "inline-flex items-center gap-0.5 p-0.5 rounded-lg " \
                   "bg-control-track"
          }
        end
      end
    end
  end
end
