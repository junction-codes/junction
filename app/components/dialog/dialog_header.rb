# frozen_string_literal: true

module Components
  # UI component to display a dialog header.
  class DialogHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    def description(*, **, &)
      render DialogDescription.new(*, **, &)
    end

    def title(*, **, &)
      render DialogTitle.new(*, **, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 text-center sm:text-left rtl:sm:text-right"
      }
    end
  end
end
