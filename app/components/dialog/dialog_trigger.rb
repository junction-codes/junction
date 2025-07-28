# frozen_string_literal: true

module Components
  class DialogTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          action: "click->ruby-ui--dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
