# frozen_string_literal: true

module Junction
  module Components
    class SelectGroup < Base
      def view_template(&)
        div(**attrs, &)
      end

      private

      def default_attrs
        {}
      end
    end
  end
end
