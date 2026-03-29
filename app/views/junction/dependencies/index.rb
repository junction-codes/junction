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
        # @param can_destroy [Boolean] Whether the current user is authorized to
        #   remove dependencies.
        # @param dependency_map [Hash] Map of [target_type, target_id] to
        #   dependency record ID, used to build delete routes.
        # @param can_create [Boolean] Whether the current user is authorized to
        #   create dependencies.
        # @param create_url [String] URL for creating new dependencies.
        # @param search_url [String] URL for the autocomplete search endpoint.
        def initialize(dependencies:, pagy:, query:, page_url:, per_page_url:,
                       sort_url:, can_destroy: false, dependency_map: {},
                       can_create: false, create_url: nil, search_url: nil)
          @dependencies = dependencies
          @pagy = pagy
          @query = query
          @page_url = page_url
          @per_page_url = per_page_url
          @sort_url = sort_url
          @can_destroy = can_destroy
          @dependency_map = dependency_map
          @can_create = can_create
          @create_url = create_url
          @search_url = search_url
        end

        def view_template
          turbo_frame_tag "dependencies" do
            div(class: "flex justify-end mb-4") { add_dependency_dialog } if @can_create

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
                                span(class: "sr-only") { t(".remove", name: dependency.name) }
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

        private

        # Renders the add dependency dialog.
        def add_dependency_dialog
          Dialog do |dialog|
            dialog.trigger do
              Button(variant: :primary, size: :sm) do
                icon("plus", class: "w-4 h-4 mr-2")
                plain t(".add_dependency")
              end
            end

            dialog.content do |content|
              content.header do |header|
                header.title { t(".add_dependency_title") }
              end

              content.body do
                form_with(
                  url: @create_url,
                  method: :post,
                  data: {
                    controller: "dependency-search",
                    "dependency-search-search-url-value": @search_url
                  }
                ) do |f|
                  div(class: "space-y-1") do
                    label(
                      for: "dependency-search-input",
                      class: "block text-sm font-medium leading-6 text-gray-900 dark:text-white mb-1"
                    ) { t(".search_label") }

                    div(class: "relative") do
                      input(
                        id: "dependency-search-input",
                        type: "text",
                        autocomplete: "off",
                        placeholder: t(".search_placeholder"),
                        data: {
                          dependency_search_target: "input",
                          action: "input->dependency-search#search " \
                                  "keydown.down->dependency-search#navigate " \
                                  "keydown.escape->dependency-search#clearResults"
                        },
                        class: "block w-full rounded-md border-0 px-3 py-1.5 pr-8 text-gray-900 " \
                               "shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 " \
                               "focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 " \
                               "dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:focus:ring-blue-500"
                      )

                      button(
                        type: "button",
                        class: "absolute inset-y-0 right-0 hidden items-center pr-2 " \
                               "text-gray-400 hover:text-gray-600 dark:hover:text-gray-300",
                        data: {
                          dependency_search_target: "clearButton",
                          action: "click->dependency-search#clear"
                        }
                      ) do
                        icon("x", class: "w-4 h-4")
                      end
                    end

                    input(
                      type: "hidden",
                      name: "dependency[target]",
                      data: { dependency_search_target: "targetValue" }
                    )

                    turbo_frame_tag "dependency-search-results",
                      class: "block mt-1",
                      data: { dependency_search_target: "results" }
                  end

                  div(class: "flex justify-end gap-x-2 mt-4") do
                    Link(
                      href: nil,
                      data: { action: "click->ruby-ui--dialog#dismiss" }
                    ) { t(".cancel") }
                    Button(
                      type: "submit",
                      variant: :primary,
                      data: { dependency_search_target: "submit" },
                      disabled: true
                    ) { t(".add_dependency") }
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
