# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # List of annotations and their values for an entity.
      class EntityAnnotationList < Base
        # Initializes the component.
        #
        # @param annotations [Array<Array(String, Object)>] Annotations to
        #   display as key/value pairs.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(annotations:, **user_attrs)
          @annotations = annotations

          super(**user_attrs)
        end

        def view_template
          dl(**attrs) do
            @annotations.each do |key, value|
              div(class: "min-w-0") do
                dt(class: "font-mono text-[11px] text-muted-foreground truncate") { key }
                dd(class: "font-mono text-[12px] font-medium text-accent-stronger " \
                          "truncate") { value.to_s }
              end
            end
          end
        end

        private

        def default_attrs
          { class: "grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-3" }
        end
      end
    end
  end
end
