# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Detail page for a Component.
      #
      # Rendering lives in {Entities::Show}. This adds where a component sits,
      # and resolves the copy in the Component translation scope.
      class Show < Entities::Show
        private

        def related_items
          related_item(@entity.system, @entity.class.human_attribute_name(:system_id))
          related_item(@entity.system&.domain, @entity.class.human_attribute_name(:domain_id))
        end
      end
    end
  end
end
