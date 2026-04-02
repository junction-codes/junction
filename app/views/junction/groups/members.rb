# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Lazy-loaded turbo frame content for a group's members table.
      class Members < Views::Base
        attr_reader :page_url, :pagy, :per_page_url, :query, :sort_url

        # Initializes the view.
        #
        # @param group [Junction::Group] The group whose members are displayed.
        # @param members [Array<Junction::User>] The members to display in the
        #   table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param query [Ransack::Search] Ransack query for sorting and
        #   filtering.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        # @param sort_url [#call] Callable that accepts a field and direction
        #   and returns a URL string.
        # @param can_destroy [Boolean] Whether the current user may remove
        #   members. When true, a delete button is shown per row.
        # @param can_create [Boolean] Whether the current user may add members.
        # @param create_url [String] URL to POST new members to.
        # @param search_url [String] URL for the autocomplete search endpoint.
        def initialize(group:, members:, pagy:, query:, page_url:, per_page_url:,
                       sort_url:, can_destroy: false, can_create: false,
                       create_url: nil, search_url: nil)
          @group = group
          @members = members
          @pagy = pagy
          @query = query
          @page_url = page_url
          @per_page_url = per_page_url
          @sort_url = sort_url
          @can_destroy = can_destroy
          @can_create = can_create
          @create_url = create_url
          @search_url = search_url
        end

        def view_template
          turbo_frame_tag "group_members" do
            div(class: "flex justify-end mb-4") { add_member_dialog } if @can_create

            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  %w[name email_address].each do |field|
                    row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                      User.human_attribute_name(field)
                    end
                  end

                  row.head { span(class: "sr-only") { t(".actions") } }
                end
              end

              table.body do |body|
                @members.each do |user|
                  body.row do |row|
                    row.cell { render_view_link(user) }
                    row.cell do
                      Link(href: "mailto:#{user.email_address}") { user.email_address }
                    end

                    row.cell(class: "text-right") do
                      next unless @can_destroy

                      Dialog do |dialog|
                        dialog.trigger do
                          Tooltip do |tooltip|
                            tooltip.trigger do
                              Button(variant: :ghost, size: :sm) do
                                icon("trash", class: "w-4 h-4 text-destructive-foreground")
                                span(class: "sr-only") { t(".remove", name: user.display_name) }
                              end
                            end

                            tooltip.content do
                              t(".remove", name: user.display_name)
                            end
                          end
                        end

                        dialog.content do |content|
                          content.header do |header|
                            header.title { t(".confirm_title", name: user.display_name) }
                          end

                          content.body do
                            t(".confirm_body", name: user.display_name)
                          end

                          content.footer do
                            Button(
                              variant: :link,
                              data: { action: "click->ruby-ui--dialog#dismiss" }
                            ) { t(".cancel") }
                            Link(
                              variant: :destructive,
                              href: group_member_path(@group, user),
                              data_turbo_method: :delete
                            ) { t(".confirm_remove") }
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil)
          end
        end

        private

        # Renders the add member dialog.
        def add_member_dialog
          Dialog do |dialog|
            dialog.trigger do
              Button(variant: :primary, size: :sm) do
                icon("plus", class: "w-4 h-4 mr-2")
                plain t(".add_member")
              end
            end

            dialog.content do |content|
              content.header do |header|
                header.title { t(".add_member_title") }
              end

              content.body do
                form_with(
                  url: @create_url,
                  method: :post,
                  data: {
                    controller: "autocomplete",
                    autocomplete_search_url_value: @search_url
                  }
                ) do |f|
                  AutocompleteField(
                    label: t(".search_label"),
                    placeholder: t(".search_placeholder"),
                    hidden_field_name: "member[user_id]",
                    frame_id: "member-search-results"
                  )

                  div(class: "flex justify-end gap-x-2 mt-4") do
                    Button(
                      variant: :link,
                      data: { action: "click->ruby-ui--dialog#dismiss" }
                    ) { t(".cancel") }
                    Button(
                      type: "submit",
                      variant: :primary,
                      data: { autocomplete_target: "submit" },
                      disabled: true
                    ) { t(".add_member") }
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
