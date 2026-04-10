# frozen_string_literal: true

module Junction
  module Components
    module Select
      class Select < Base
        def view_template(&)
          div(**attrs, &)
        end

        def content(...)
          render SelectContent.new(...)
        end

        def input(...)
          render Input.new(...)
        end

        def trigger(...)
          render SelectTrigger.new(...)
        end

        private

        def default_attrs
          {
            data: {
              controller: "ruby-ui--select",
              ruby_ui__select_open_value: "false",
              action: "click@window->ruby-ui--select#clickOutside",
              ruby_ui__select_ruby_ui__select_item_outlet: ".item"
            },
            class: "group/select w-full relative"
          }
        end
      end
    end
  end
end
