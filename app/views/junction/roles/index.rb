# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Index view for Roles.
      class Index < Views::Base
        attr_reader :query, :roles, :can_create

        # Initialize a new view.
        #
        # @param roles [ActiveRecord::Relation] Collection of roles to display.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param can_create [Boolean] Whether the user can create roles.
        def initialize(roles:, query:, can_create: true)
          @roles = roles
          @query = query
          @can_create = can_create
        end

        def view_template
          render Junction::Layouts::Application do
            div(class: "p-6") do
              div(class: "flex justify-between items-center mb-6") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t("views.roles.index.title") }
                if @can_create
                  Link(variant: :primary, href: new_role_path) { t("views.roles.index.new_role") }
                end
              end

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                render Table do |table|
                  table.header do |header|
                    header.row do |row|
                      row.cell(class: "font-medium") { t("views.roles.index.name") }
                      row.cell(class: "font-medium") { t("views.roles.index.description") }
                      row.cell(class: "font-medium") { t("views.roles.index.permissions") }
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
                              ? t("views.roles.index.permissions_all")
                              : t("views.roles.index.permissions_all_read")
                          else
                            plain role.role_permissions.count
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
    end
  end
end
