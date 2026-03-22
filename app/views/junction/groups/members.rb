# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Lazy-loaded turbo frame content for a group's members table.
      class Members < Views::Base
        attr_reader :page_url, :per_page_url, :pagy

        # Initializes the view.
        #
        # @param members [Array<Junction::User>] The members to display in the
        #   table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        def initialize(members:, pagy:, page_url:, per_page_url:)
          @members = members
          @pagy = pagy
          @page_url = page_url
          @per_page_url = per_page_url
        end

        def view_template
          turbo_frame_tag "group_members" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.groups.members.name") }
                  row.head { t("views.groups.members.email") }
                end
              end

              table.body do |body|
                @members.each do |user|
                  body.row do |row|
                    row.cell { render_view_link(user) }
                    row.cell do
                      Link(href: "mailto:#{user.email_address}") { user.email_address }
                    end
                  end
                end
              end
            end

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil,
                          turbo_frame: "group_members")
          end
        end
      end
    end
  end
end
