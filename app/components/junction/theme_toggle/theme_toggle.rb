# frozen_string_literal: true

module Junction
  module Components
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
              Button(variant: :ghost, icon: true) { icon("moon", class: "w-4 h-4") }
            end

            t.content { "Switch to light mode" }
          end
        end
      end

      def light_mode
        SetLightMode do
          Tooltip(placement: "bottom") do |t|
            t.trigger do
              Button(variant: :ghost, icon: true) { icon("sun", class: "w-4 h-4") }
            end

            t.content { "Switch to dark mode" }
          end
        end
      end
    end
  end
end
