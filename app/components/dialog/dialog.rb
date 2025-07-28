# frozen_string_literal: true

module Components
  class Dialog < Base
    def initialize(open: false, **attrs)
      @open = open

      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    def trigger(*, **, &)
      render DialogTrigger.new(*, **, &)
    end

    def content(*, **, &)
      render DialogContent.new(*, **, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--dialog",
          ruby_ui__dialog_open_value: @open
        }
      }
    end
  end
end
