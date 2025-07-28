# frozen_string_literal: true

module Components
  class Card < Base
    def view_template(&)
      div(**attrs, &)
    end

    def content(*, **, &)
      render CardContent.new(*, **, &)
    end

    def footer(*, **, &)
      render CardFooter.new(*, **, &)
    end

    def header(*, **, &)
      render CardHeader.new(*, **, &)
    end

    private

    def default_attrs
      {
        class: "rounded-xl border shadow bg-white dark:bg-gray-800 overflow-hidden"
      }
    end
  end
end
