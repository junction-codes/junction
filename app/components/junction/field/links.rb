# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form controls for managing an entity's links.
      class Links < RowSet
        def self.columns
          %i[url title icon]
        end

        private

        # Ends with a blank row so there is always somewhere to type the next
        # link. Unlike labels, links need no virtual attribute;
        # `Linkable#links=` already accepts the indexed rows a form submits.
        #
        # @return [Array<Hash>] The rows.
        def rows
          entity.links + [ {} ]
        end
      end
    end
  end
end
