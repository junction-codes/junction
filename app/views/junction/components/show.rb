# frozen_string_literal: true

module Junction
  module Views
    module Components
      # Detail page for a Component.
      #
      # Rendering lives in {Entities::Show}. This adds where a component sits
      # and the way to its repository, and resolves the copy in the Component
      # translation scope.
      class Show < Entities::Show
        private

        def related_items
          related_item(@entity.system, @entity.class.human_attribute_name(:system_id))
          related_item(@entity.system&.domain, @entity.class.human_attribute_name(:domain_id))
        end

        def header_actions
          return if @entity.repository_url.blank?

          Link(href: @entity.repository_url, variant: :outline,
               target: "_blank", rel: "noopener noreferrer",
               class: "border-border bg-surface shadow-none text-[13.5px] " \
                      "text-text-strong gap-2") do
            icon("external-link", class: "w-4 h-4")
            plain t(".open_repo")
          end
        end
      end
    end
  end
end
