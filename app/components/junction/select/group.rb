# frozen_string_literal: true

module Junction
  module Components
    module Select
      class Group < Base
        def view_template(&)
          div(**attrs, &)
        end

        def item(...)
          render SelectItem.new(...)
        end

        def link(...)
          render Link.new(...)
        end

        private

        def default_attrs
          {}
        end
      end
    end
  end
end
