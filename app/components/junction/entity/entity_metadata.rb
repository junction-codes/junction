# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Shows an entity's tags, labels and links.
      #
      # The three are easy to confuse, so they are shown together and labelled:
      # tags are free-form and filterable, labels are exact-match pairs for
      # machines, and links point outside Junction. Annotations are deliberately
      # not here; they configure plugins rather than describe the entity.
      class EntityMetadata < Base
        include Junction::EntityCopy

        TAG_CLASSES = <<~CSS
          inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs
          font-medium text-gray-700 dark:bg-gray-700 dark:text-gray-100
        CSS

        LABEL_CLASSES = <<~CSS
          inline-flex items-center gap-1 rounded-md bg-gray-100 px-2 py-1
          text-xs dark:bg-gray-700
        CSS

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity to describe.
        def initialize(entity:)
          @entity = entity

          super()
        end

        def view_template
          Card do |card|
            card.header do |header|
              header.title { t(".title") }
              header.description { t(".description") }
            end

            card.content(class: "space-y-6") do
              section(t(".tags")) { tag_list }
              section(t(".labels")) { label_list }
              section(t(".links")) { link_list }
            end
          end
        end

        private

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        # Renders one titled section, or a muted note when it is empty.
        #
        # @param title [String] The section's heading.
        def section(title)
          div do
            h4(class: "text-sm font-semibold text-gray-900 " \
                       "dark:text-gray-100 mb-2") do
              title
            end

            yield
          end
        end

        def tag_list
          return none if @entity.tags.blank?

          div(class: "flex flex-wrap gap-2") do
            @entity.tags.each do |tag|
              span(class: TAG_CLASSES) { tag }
            end
          end
        end

        def label_list
          return none if @entity.labels.blank?

          dl(class: "flex flex-wrap gap-2") do
            @entity.labels.each do |key, value|
              div(class: LABEL_CLASSES) do
                dt(class: "font-mono font-medium text-gray-700 " \
                          "dark:text-gray-100") { key }
                dd(class: "font-mono text-gray-600 dark:text-gray-400") do
                  "= #{value}"
                end
              end
            end
          end
        end

        def link_list
          return none if @entity.links.blank?

          ul(class: "space-y-1") do
            @entity.links.each do |link|
              li(class: "flex items-center gap-2 text-sm") do
                icon(link["icon"], fallback: "link",
                     class: "w-4 h-4 text-gray-400")
                Link(href: link["url"], variant: :link, class: "p-0") do
                  link["title"].presence || link["url"]
                end
              end
            end
          end
        end

        # Renders the muted stand-in for an empty section.
        def none
          p(class: "text-sm text-gray-400 dark:text-gray-500") { t(".none") }
        end
      end
    end
  end
end
