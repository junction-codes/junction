# frozen_string_literal: true

module Components
  class CardContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    def description(*, **, &)
      render CardDescription.new(*, **, &)
    end

    private

    def default_attrs
      {
        class: "p-6 pt-0"
      }
    end
  end
end
