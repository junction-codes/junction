# frozen_string_literal: true

module Components
  class DropdownMenuTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    def button(*, **, &)
      render Button.new(*, **, &)
    end

    private

    def default_attrs
      {
        data: { ruby_ui__dropdown_menu_target: "trigger", action: "click->ruby-ui--dropdown-menu#toggle" },
        class: "inline-block"
      }
    end
  end
end
