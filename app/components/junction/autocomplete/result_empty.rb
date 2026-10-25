# frozen_string_literal: true

module Junction
  module Components
    module Autocomplete
      # Empty state for autocomplete search results.
      #
      # @example
      #   ResultEmpty do
      #     "No results found"
      #   end
      class ResultEmpty < Base
        def view_template
          div(**attrs) do
            p(class: "px-3 py-4 text-sm text-text-tertiary text-center") do
              yield
            end
          end
        end

        private

        def default_attrs
          {
            class: "border border-border rounded-md"
          }
        end
      end
    end
  end
end
