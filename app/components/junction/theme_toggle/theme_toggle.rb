# frozen_string_literal: true

module Junction
  module Components
    module ThemeToggle
      # UI component to toggle the theme between light and dark.
      class ThemeToggle < Base
        def view_template
          div(**attrs) do
            dark_mode
            light_mode
          end
        end

        private

        def dark_mode
          SetDarkMode do
            Tooltip(placement: "bottom") do |t|
              t.trigger do
                Button(variant: :ghost, icon: true,
                       aria_label: t(".set_light")) do
                  icon("moon", class: "w-4 h-4")
                end
              end

              t.content { t(".set_light") }
            end
          end
        end

        def light_mode
          SetLightMode do
            Tooltip(placement: "bottom") do |t|
              t.trigger do
                Button(variant: :ghost, icon: true,
                       aria_label: t(".set_dark")) do
                  icon("sun", class: "w-4 h-4")
                end
              end

              t.content { t(".set_dark") }
            end
          end
        end
      end
    end
  end
end
