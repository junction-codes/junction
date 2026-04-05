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
                  %w[name type].each do |field|
                    row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                      t(".#{field}")
                    end
                  end

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
                                span(class: "sr-only") { t(".remove", name: dependency.title) }
                              end
                            end

                            tooltip.content do
                              t(".remove", name: dependency.title)
                            end
                          end
                        end

                        dialog.content do |content|
                          content.header do |header|
                            header.title { t(".confirm_title", name: dependency.title) }
                          end

                          content.body do
                            t(".confirm_body", name: dependency.title)
                          end

                          content.footer do
                            Button(
                              variant: :link,
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
                    controller: "autocomplete",
                    autocomplete_search_url_value: @search_url
                  }
                ) do |f|
                  AutocompleteField(
                    label: t(".search_label"),
                    placeholder: t(".search_placeholder"),
                    hidden_field_name: "dependency[target]",
                    frame_id: "dependency-search-results"
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
