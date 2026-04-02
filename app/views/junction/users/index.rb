# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Index view for users.
      class Index < Views::Base
        attr_reader :breadcrumbs, :can_create, :pagy, :query, :query_params,
                    :users

        # Initializes the view.
        #
        # @param users [ActiveRecord::Relation] Collection of users to display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param can_create [Boolean] Whether the user can create users.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(users:, query:, pagy:, can_create: true, breadcrumbs: [],
                       query_params: {})
          @users = users
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Users" }
                if @can_create
                  Link(variant: :primary, href: new_user_path) { "New User" }
                end
              end

              UserFilters(query:)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                render Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { users_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { users_path(q: @query_params, per_page:) }
              )
            end
          end
        end

        private

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                users_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              %w[display_name email_address].each do |field|
                row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                  User.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @users.each do |user|
              body.row do |row|
                row.cell do
                  div(class: "flex items-center space-x-4") do
                    # Logo or placeholder image.
                    if user.image_url.present?
                      img(src: user.image_url, alt: "#{user.display_name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
                    else
                      div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                        icon("user-round", class: "h-6 w-6 text-gray-500")
                      end
                    end

                    div do
                      div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                        a(href: user_path(user)) { user.display_name }
                      end

                      div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { user.pronouns }
                    end
                  end
                end

                row.cell do
                  Link(href: "mailto:#{user.email_address}", class: "ps-0") { user.email_address }
                end
              end
            end
          end
        end
      end
    end
  end
end
