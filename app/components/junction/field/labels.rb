# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form controls for managing the labels of an entity.
      #
      # Labels are exact-match key/value pairs meant for machines: filters,
      # plugin selectors, cost attribution, etc. The rows are submitted as
      # `label_rows` rather than as the labels themselves, because the key has
      # to be editable and it cannot be while it is the parameter name.
      class Labels < RowSet
        def self.columns
          %i[key value]
        end

        private

        def rows
          entity.label_rows
        end
      end
    end
  end
end
