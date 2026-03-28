# frozen_string_literal: true

module Junction
  module Views
    module Dependencies
      # Lazy-loaded turbo frame content for a dependency table.
      class Index < Views::Base
        attr_reader :page_url, :pagy, :per_page_url, :query, :sort_url

        # Initializes the view.
        #
        # @param dependencies [Array] The dependency target entities to display.
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
        #   dependencies. When true, a delete button is shown per row.
        # @param dependency_map [Hash] Map of [target_type, target_id] to
        #   Dependency record ID, used to build delete routes.
        def initialize(dependencies:, pagy:, query:, page_url:, per_page_url:,
                       sort_url:, can_destroy: false, dependency_map: {})
          @dependencies = dependencies
          @pagy = pagy
          @query = query
          @page_url = page_url
          @per_page_url = per_page_url
          @sort_url = sort_url
          @can_destroy = can_destroy
          @dependency_map = dependency_map
        end

        def view_template
          turbo_frame_tag "dependencies" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.sortable_head(query:, field: "name", sort_url:) { t(".name") }
                  row.sortable_head(query:, field: "type", sort_url:) { t(".type") }
                  row.head { span(class: "sr-only") { t(".actions") } }
                end
              end

              table.body do |body|
                @dependencies.each do |dependency|
                  body.row do |row|
                    row.cell { render_view_link(dependency) }
                    row.cell { dependency.type }

                    key = [ dependency.class.name, dependency.id ]
                    dep_id = @dependency_map[key]
                    row.cell(class: "text-right") do
                      next unless dep_id && @can_destroy

                      Dialog do |dialog|
                        dialog.trigger do
                          Tooltip do |tooltip|
                            tooltip.trigger do
                              Button(variant: :ghost, size: :sm) do
                                icon("trash", class: "w-4 h-4 text-destructive-foreground")
                              end
                            end

                            tooltip.content do
                              t(".remove", name: dependency.name)
                            end
                          end
                        end

                        dialog.content do |content|
                          content.header do |header|
                            header.title { t(".confirm_title", name: dependency.name) }
                          end

                          content.body do
                            t(".confirm_body", name: dependency.name)
                          end

                          content.footer do
                            Link(
                              href: nil,
                              data: { action: "click->ruby-ui--dialog#dismiss" }
                            ) { t(".cancel") }
                            Link(
                              variant: :destructive,
                              href: dependency_path(dep_id),
                              data_turbo_method: :delete
                            ) { t(".confirm_delete") }
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
      end
    end
  end
end
