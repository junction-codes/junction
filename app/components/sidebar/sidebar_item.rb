# frozen_string_literal: true

module Components
  class SidebarItem < Base
    def initialize(icon:, title:, disabled: false, **user_attrs)
      @icon = icon
      @title = title
      @disabled = disabled

      super(**user_attrs)
    end

    def view_template
      div do
        render Link.new(variant: @disabled ? :disabled : :link, **attrs) do
          span(class: "flex-shrink-0") { icon(@icon, class: "w-6 h-6") }
          span(data_sidebar_target: "linkText", class: "ml-4 whitespace-nowrap") { @title }
        end
      end
    end
  end
end
