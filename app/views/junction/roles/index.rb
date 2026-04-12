# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Index view for Roles.
      class Index < Views::Base
        attr_reader :breadcrumbs, :can_create, :pagy, :query, :query_params,
                    :roles

        # Initialize a new view.
        #
        # @param roles [ActiveRecord::Relation] Collection of roles to display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param can_create [Boolean] Whether the user can create roles.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        def initialize(roles:, query:, pagy:, can_create: true, breadcrumbs: [],
                       query_params: {})
          @roles = roles
          @query = query
          @query_params = query_params
          @pagy = pagy
          @can_create = can_create
          @breadcrumbs = breadcrumbs
        end

        private

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                  Junction::Role.model_name.human(count: 2)
                end

                if @can_create
                  Link(variant: :primary, href: new_role_path) { t(".new") }
                end
              end

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table.header do |header|
                    header.row do |row|
                      sort_url = ->(field, direction) {
                        roles_path(
                          q: @query_params.merge(s: "#{field} #{direction}"),
                          per_page: @pagy.options[:limit]
                        )
                      }

                      row.sortable_head(field: "title", sort_url:, **sort_attrs(query, "title")) do
                        Role.human_attribute_name("title")
                      end

                      row.cell { Role.human_attribute_name("description") }
                      row.cell { Role.human_attribute_name("permissions") }
                    end
                  end

                  table.body do |body|
                    @roles.each do |role|
                      body.row do |row|
                        row.cell do
                          render_view_link(role, class: "ps-0")
                        end

                        row.cell { role.description }

                        row.cell(class: "text-right") do
                          if role.system?
                            plain role.name == Junction::Permissions::UserPermissions::ADMIN_ROLE_NAME \
                              ? t(".permissions_all")
                              : t(".permissions_all_read")
                          else
                            plain role.role_permissions.count
                          end
                        end
                      end
                    end
                  end
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { roles_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { roles_path(q: @query_params, per_page:) }
              )
            end
          end
        end
      end
    end
  end
end
