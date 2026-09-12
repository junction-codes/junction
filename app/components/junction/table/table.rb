# frozen_string_literal: true

module Junction
  module Components
    module Table
      class Table < Base
        # Initializes the component.
        #
        # @param fixed [Boolean] Whether the table should use a fixed layout,
        #   which draws its columns from the table's CSS-defined
        #   widths rather than from its contents.
        # @param min_width [Integer] Minimum width the table may occupy, in
        #   pixels.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(fixed: false, min_width: nil, **user_attrs)
          @fixed = fixed
          @min_width = min_width

          super(**user_attrs)
        end

        def view_template(&)
          div(class: "relative w-full overflow-x-auto") do
            table(style: table_style, **table_attrs, &)
          end
        end

        def body(...)
          render Body.new(...)
        end

        def caption(...)
          render Caption.new(...)
        end

        def footer(...)
          render TableFooter.new(...)
        end

        def header(...)
          render TableHeader.new(...)
        end

        private

        # A clipped table hides part of its values, so it carries the
        # controller that hands them back on hover.
        #
        # @return [Hash] The table's HTML attributes.
        def table_attrs
          return attrs unless @fixed

          mix({ data: { controller: "overflow-title" } }, attrs)
        end

        # @return [String, nil] The inline style, when a floor was given.
        def table_style
          "min-width: #{@min_width}px" if @min_width
        end

        def default_attrs
          {
            class: [
              "w-full caption-bottom text-sm",
              # A fixed table does not clip on its own, so anything wider than
              # its column paints over the next one.
              ("table-fixed [&_td]:overflow-hidden [&_th]:overflow-hidden" if @fixed)
            ]
          }
        end
      end
    end
  end
end
