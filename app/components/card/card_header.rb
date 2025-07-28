# frozen_string_literal: true

module Components
  class CardHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    def description(*, **, &)
      render CardDescription.new(*, **, &)
    end

    def title(*, **, &)
      render CardTitle.new(*, **, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 p-6"
      }
    end
  end
end
