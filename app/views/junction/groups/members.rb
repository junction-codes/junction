# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Lazy-loaded turbo frame content for a group's members table.
      class Members < Views::Base
        # Initializes the view.
        #
        # @param members [Array<Junction::User>] The members to display in the
        #   table.
        def initialize(members:)
          @members = members
        end

        def view_template
          turbo_frame_tag "group_members" do
            Table do |table|
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
          end
        end
      end
    end
  end
end
