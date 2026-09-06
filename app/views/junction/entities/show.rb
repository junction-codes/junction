# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Detail page for a catalog entity.
      #
      # The header, the stat row and the dependency tabs are the same for every
      # kind. What differs is which meta rows sit under the description, which
      # parent the entity is "part of", and what fills the tabs, each a hook
      # that a kind view overrides.
      class Show < Views::Base
        include PluginDispatchHelper
        include Junction::EntityCopy

        share_translations

        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param entity [Junction::Entity] The entity being shown.
        # @param can_edit [Boolean] Whether the user may edit it.
        # @param can_destroy [Boolean] Whether the user may delete it.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param options [Hash] Extra arguments from the controller's
        #   `show_options`.
        def initialize(entity:, can_edit:, can_destroy:, breadcrumbs: [],
                       **options)
          @entity = entity
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-8") do
              entity_header
              entity_stats
              body
            end
          end
        end

        private

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        def entity_header
          div(class: "flex justify-between items-start") do
            div(class: "flex items-center space-x-6") do
              header_image
              header_details
              div { parent_link }
            end

            div(class: "flex-shrink-0") { edit_button if @can_edit }
          end
        end

        def header_image
          if @entity.image_url.present?
            img(src: @entity.image_url, alt: t(".logo_alt", name: @entity.title),
                class: "h-20 w-20 rounded-lg object-cover flex-shrink-0")
          else
            div(class: "h-20 w-20 rounded-lg bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
              icon(@entity.icon, class: "h-10 w-10 text-gray-500")
            end
          end
        end

        def header_details
          div do
            h2(class: "text-3xl font-bold text-gray-900 dark:text-white") { @entity.title }
            p(class: "mt-1 text-md text-gray-600 dark:text-gray-400 max-w-2xl") { @entity.description }

            meta_rows
          end
        end

        # Rows of `Label: value` under the description.
        #
        # Overridden by kinds; the owner row is the one nearly all of them
        # share.
        def meta_rows
          owner_row
        end

        # Renders the owning group, or the fact that there isn't one.
        def owner_row
          meta_row(@entity.class.human_attribute_name(:owner_id)) do
            if @entity.owner.present?
              span { render_view_link(@entity.owner, class: "p-0 inline") }
            else
              span { plain t(".no_owner") }
            end
          end
        end

        # Renders one meta row.
        #
        # @param label [String] The row's label.
        def meta_row(label, &block)
          div(class: "mt-2 flex items-center text-sm text-gray-500 dark:text-gray-400") do
            span(class: "font-semibold mr-2") { "#{label}:" }
            yield
          end
        end

        # The "part of ..." line beside the header. Nothing by default.
        def parent_link
        end

        # Renders a link to the entity this one belongs to, greyed out when the
        # user may not open it.
        #
        # @param related [Junction::Entity, nil] The related entity.
        # @param key [Symbol] Translation key for the phrasing.
        # @param interpolation [Symbol] Name the title interpolates as.
        def related_link(related, key, interpolation)
          return if related.nil?

          label = t(".#{key}", interpolation => related.title)

          if allowed_to?(:show?, related)
            Link(href: junction_catalog_path(related)) { label }
          else
            Link(variant: :disabled) { label }
          end
        end

        def edit_button
          Link(variant: :primary, href: junction_edit_catalog_path(@entity)) do
            icon("pencil", class: "w-4 h-4 mr-2")
            plain t(".edit")
          end
        end

        def entity_stats
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6") do
            # TODO: Remove placeholder.
            render StatCard.new(title: t(".stat_active_incidents"), value: "1",
                                icon: "siren", status: :warning)

            render_plugin_ui_components(context: @entity, slot: :overview_cards)
          end
        end

        # Everything below the stat row. Kinds override this.
        def body
          entity_tabs
        end

        # The tab strip. Kinds add their own triggers and panes by overriding
        # {#tab_triggers} and {#tab_panes}.
        def entity_tabs
          Tabs do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") do
                icon("blocks", class: "pe-2")
                plain t(".dependencies")
              end

              tab_triggers(list)

              render_plugin_tab_triggers(@entity, list)
            end

            tabs.content(value: "dependencies") { dependencies_section }

            tab_panes(tabs)

            render_plugin_tab_content(@entity, tabs)
          end
        end

        # @param list [Object] The tab list being built.
        def tab_triggers(list)
        end

        # @param tabs [Object] The tab set being built.
        def tab_panes(tabs)
        end

        def dependencies_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") do
              t(".dependencies")
            end

            Tabs(default: "dependencies") do |tabs|
              tabs.list do |list|
                list.trigger(value: "dependencies") { t(".dependencies") }
                list.trigger(value: "dependents") { t(".dependents") }
                list.trigger(value: "graph") { t(".graph") }
              end

              tabs.content(value: "dependencies") do
                turbo_frame_tag "dependencies", src: junction_dependencies_path(@entity), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "dependents") do
                turbo_frame_tag "dependents", src: junction_dependents_path(@entity), loading: :lazy do
                  div(class: "p-4") { Skeleton(class: "h-20") }
                end
              end

              tabs.content(value: "graph") { dependency_graph }
            end
          end
        end

        def dependency_graph
          div do
            div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden p-5") do
              div(data_controller: "graph",
                  data_graph_url_value: junction_dependency_graph_path(@entity)) do
                div(data_graph_target: "container", class: "w-full h-60")
              end
            end
          end
        end
      end
    end
  end
end
