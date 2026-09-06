# frozen_string_literal: true

module Junction
  module Views
    module Resources
      # Detail page for a Resource.
      #
      # Rendering lives in {Entities::Show}; this adds the rows a resource has
      # of its own and resolves the copy in the Resource translation scope.
      class Show < Entities::Show
        private

        def meta_rows
          owner_row
          type_row
        end

        def type_row
          meta_row(@entity.class.human_attribute_name(:type)) do
            span { plain @entity.type }
          end
        end

        def parent_link
          related_link(@entity.system, :part_of_system, :system_title)
        end
      end
    end
  end
end
