# frozen_string_literal: true

module Junction
  module Components
    module DropdownMenu
      class DropdownMenuItem < Base
        def initialize(as: :a, href: "#", **user_attrs)
          @as = as
          @href = href

          super(**user_attrs)
        end

        def view_template(&)
          if @as == :div
            div(**attrs, &)
          else
            a(**attrs, &)
          end
        end

        private

        def default_attrs
          base = {
            role: "menuitem",
            class: "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            data_action: "click->ruby-ui--dropdown-menu#close",
            data_ruby_ui__dropdown_menu_target: "menuItem",
            tabindex: "-1",
            data_orientation: "vertical"
          }

          base[:href] = @href unless @as == :div
          base
        end
      end
    end
  end
end
