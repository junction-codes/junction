# frozen_string_literal: true

module Components
  class DialogTitle < Base
    def view_template(&)
      h3(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "text-lg font-semibold leading-none text-gray-900 dark:text-white tracking-tight"
      }
    end
  end
end
