# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Links defined for an entity.
      class EntityLinksCard < Base
        share_translations

        LINK_ICON = "link"

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity:, **user_attrs)
          @entity = entity

          super(**user_attrs)
        end

        def view_template
          EntityCard(title: t(".title"), **attrs) do
            if links.empty?
              p(class: "text-[12px] text-muted-foreground") { t(".none") }
            else
              ul(class: "space-y-3") { links.each { |link| row(link) } }
            end
          end
        end

        private

        # A row for an individual link.
        #
        # @param link [Hash<String, String>] The link details.
        # @option link [String] "url" The link's URL.
        # @option link [String] "title" The link's title.
        # @option link [String] "icon" The link's icon.
        def row(link)
          url = link["url"].to_s

          li do
            a(href: url, target: "_blank", rel: "noopener noreferrer",
              class: "group flex items-center gap-2.5 min-w-0") do
              icon(link["icon"].presence || LINK_ICON, fallback: LINK_ICON,
                   class: "w-[15px] h-[15px] shrink-0 text-muted-foreground")
              span(class: "text-[12.5px] font-medium text-text-strong " \
                          "truncate group-hover:underline") do
                link["title"].presence || url
              end
              span(class: "ml-auto pl-3 text-[11px] text-muted-foreground " \
                          "truncate") { host(url) }
            end
          end
        end

        # Parses the destination host of a url.
        #
        # @param url [String] The link's address.
        # @return [String, nil] The host, without a leading `www.`.
        def host(url)
          URI.parse(url).host&.delete_prefix("www.")
        rescue URI::InvalidURIError
          nil
        end

        def links
          @links ||= Array(@entity.links)
        end
      end
    end
  end
end
