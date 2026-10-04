# frozen_string_literal: true

module Junction
  module Views
    module Plugins
      # The plugins settings page.
      class Index < Views::Base
        # How many registrations a card lists before it cuts off.
        ITEM_LIMIT = 6

        # Initializes the view.
        #
        # @param overview [Junction::Plugins::Overview] Overview of all plugins.
        # @param breadcrumbs [Array<Hash>] Breadcrumb trail items.
        def initialize(overview:, breadcrumbs: [])
          @overview = overview
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs: @breadcrumbs) do
            SettingsPage(title: t(".title"), description: t(".description")) do |page|
              plugins = @overview.plugins

              if plugins.empty?
                p(class: "text-sm text-text-tertiary") { t(".empty_plugins") }
                next
              end

              page.panes(default: plugins.first.id) do |panes|
                index_pane(panes)
                plugins.each { |plugin| detail_pane(panes, plugin) }
              end
            end
          end
        end

        private

        # Renders the index pane containing the list of plugins.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def index_pane(panes)
          panes.index do |index|
            index.list do |list|
              plugin_group(list, t(".core_plugins"), @overview.core)
              plugin_group(list, t(".external_plugins"), @overview.installed)
            end

            index.footnote do
              t(@overview.installed.empty? ? ".no_external" : ".gemfile_note")
            end
          end
        end

        # Renders a group of plugins within the index pane.
        #
        # @param list [Components::Settings::SettingsIndexList] The rows.
        # @param label [String] Label for the group.
        # @param plugins [Array<Junction::Plugins::Overview::Summary>] The
        #   group's plugins.
        def plugin_group(list, label, plugins)
          return if plugins.empty?

          list.group(label) do |group|
            plugins.each do |plugin|
              group.item(value: plugin.id, label: plugin.title,
                         sublabel: plugin.id)
            end
          end
        end

        # Renders the detail pane for a single plugin.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        # @param plugin [Junction::Plugins::Overview::Summary] The plugin.
        def detail_pane(panes, plugin)
          panes.detail(value: plugin.id) do
            div(class: "space-y-6") do
              SettingsDetailHeader(
                title: plugin.title, mono: false, subtitle: meta(plugin),
                description: plugin.description.presence || t(".empty_description"),
                badge: { label: t(".installed"), variant: :outline }
              )

              registrations(plugin)
              provenance(plugin)
            end
          end
        end

        # Renders the meta information for a plugin.
        #
        # @param plugin [Junction::Plugins::Overview::Summary] The plugin.
        # @return [String] Plugin metadata.
        def meta(plugin)
          domain = t(".domain", domain: plugin.domain) if plugin.domain.present?

          [ plugin.id, domain ].compact.join("  ·  ")
        end

        # Renders the groups of registrations for a plugin.
        #
        # @param plugin [Junction::Plugins::Overview::Summary] The plugin.
        def registrations(plugin)
          section(class: "space-y-3") do
            div do
              h3(class: "text-[14px] font-semibold text-foreground") do
                t(".registrations")
              end
              p(class: "text-[12.5px] text-text-tertiary") { t(".registrations_note") }
            end

            div(class: "grid grid-cols-1 md:grid-cols-2 gap-3") do
              plugin.groups.each { |group| registration_card(group) }
            end
          end
        end

        # Renders a single registration card for a group.
        #
        # @param group [Hash] One `{ id:, items: }` group.
        def registration_card(group)
          items = group.fetch(:items)

          div(class: "rounded-lg border border-border bg-background p-3 " \
                     "space-y-2 min-w-0") do
            div(class: "flex items-center justify-between gap-2") do
              span(class: "text-[12.5px] font-medium text-text-strong") do
                t(".groups.#{group.fetch(:id)}")
              end
              TabCount(value: items.size)
            end

            if items.empty?
              p(class: "text-[11.5px] text-text-tertiary") { t(".none") }
              next
            end

            ul(class: "space-y-0.5") do
              items.first(ITEM_LIMIT).each do |item|
                li(class: "font-mono text-[11.5px] text-text-tertiary truncate") do
                  item
                end
              end
            end

            if items.size > ITEM_LIMIT
              p(class: "text-[11.5px] text-text-tertiary") do
                t(".and_more", count: items.size - ITEM_LIMIT)
              end
            end
          end
        end

        # Source of the plugin, indicating where it's declared.
        #
        # @param plugin [Junction::Plugins::Overview::Summary] The plugin.
        def provenance(plugin)
          section(class: "space-y-1 border-t border-border pt-4") do
            h3(class: "text-[14px] font-semibold text-foreground") do
              t(".registered_as")
            end

            p(class: "font-mono text-[13px] text-text-body") { plugin.class_name }

            if plugin.source_path
              p(class: "font-mono text-[11.5px] text-text-tertiary break-all") do
                plugin.source_path
              end
            end
          end
        end
      end
    end
  end
end
