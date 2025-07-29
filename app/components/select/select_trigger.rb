# frozen_string_literal: true

module Components
  class SelectTrigger < Base
    def view_template(&block)
      button(**attrs) do
        block&.call
        icon("chevrons-up-down", class: "h-4 w-4")
      end
    end

    private

    def default_attrs
      {
        data: {
          action: "ruby-ui--select#onClick",
          ruby_ui__select_target: "trigger"
        },
        type: "button",
        role: "combobox",
        aria: {
          controls: "radix-:r0:",
          expanded: "false",
          autocomplete: "none",
          haspopup: "listbox",
          activedescendant: true
        },
        class:
          "cursor-pointer truncate w-full flex h-9 items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
      }
    end
  end
end
