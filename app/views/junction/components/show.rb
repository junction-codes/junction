# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Detail page for a Component.
      #
      # Rendering lives in {Entities::Show}; this adds the rows a component has
      # of its own and resolves the copy in the Component translation scope.
      class Show < Entities::Show
        private

        def meta_rows
          owner_row
          type_row
          repository_row
        end

        def type_row
          meta_row(@entity.class.human_attribute_name(:type)) do
            span { plain @entity.type }
          end
        end

        def repository_row
          return if @entity.repository_url.blank?

          meta_row(@entity.class.human_attribute_name(:repository_url)) do
            span do
              Link(href: @entity.repository_url,
                   class: "p-0 text-blue-600 hover:underline dark:text-blue-400 inline") do
                @entity.repository_url
              end
            end
          end
        end

        def parent_link
          related_link(@entity.system, :part_of_system, :system_title)
        end
      end
    end
  end
end
