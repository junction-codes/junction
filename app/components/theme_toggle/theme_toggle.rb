# frozen_string_literal: true

module Components
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
        Button(variant: :ghost, icon: true, title: "Switch to light mode") do
          icon("moon", class: "w-4 h-4")
        end
      end
    end

    def light_mode
      SetLightMode do
        Button(variant: :ghost, icon: true, title: "Switch to dark mode") do
          icon("sun", class: "w-4 h-4")
        end
      end
    end
  end
end
