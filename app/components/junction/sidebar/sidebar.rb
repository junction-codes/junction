# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      class Sidebar < Base
        include PluginDispatchHelper

        # Kinds shown in the main navigation, grouped and ordered the way the
        # rail presents them. Only the grouping and order live here; the icon,
        # path, and title come from the kind registry.
        NAV_SECTIONS = {
          catalog: %i[domain system component api resource],
          people: %i[group user]
        }.freeze

        # Rows under `Explore` that have no page behind them yet. They are
        # listed rather than hidden so the shape of the product is visible,
        # and marked so nobody mistakes them for something they can open.
        SOON = [
          [ :scorecards, "shield-check" ],
          [ :techdocs, "book-open" ],
          [ :cost_explorer, "dollar-sign" ]
        ].freeze

        def view_template
          # The whole rail is the landmark, not just the list of links. An
          # inner `nav` would leave the masthead, the search box and the
          # account row outside any landmark, which is content a screen reader
          # can only reach by walking the page top to bottom.
          nav(id: "junction-sidebar", aria_label: t(".navigation"),
              data_sidebar_target: "sidebar", **attrs) do
            render_masthead
            SidebarSearch()

            div(class: "flex-1 overflow-y-auto px-4 pb-4") do
              home_item
              NAV_SECTIONS.each { |name, scopes| kind_section(name, scopes) }
              explore_section
            end

            # Demo mode reaches this layout with nobody signed in, and an
            # account menu with no account behind it has nothing to show.
            if Junction::Current.user
              AccountMenu(user: Junction::Current.user,
                          settings_items: plugin_settings_menu_items)
            end
          end
        end

        def item(...)
          render SidebarItem.new(...)
        end

        private

        # The product name, and the organization whose catalog this is.
        def render_masthead
          div(class: "flex items-center gap-2 px-4 pt-3.5 pb-3") do
            span(class: "w-[30px] h-[30px] shrink-0 rounded-[9px] " \
                        "bg-accent-muted text-primary-foreground " \
                        "flex items-center justify-center") do
              icon(Junction.config.icon, fallback: Junction::CorePlugin.icon,
                   class: "w-[18px] h-[18px]")
            end

            span(data_sidebar_target: "linkText",
                 class: "min-w-0 flex flex-col") do
              span(class: "text-[15px] font-bold leading-5 truncate") do
                t("app.title")
              end

              if organization_name.present?
                span(class: "text-[11.5px] leading-4 text-muted-foreground " \
                            "truncate") { organization_name }
              end
            end
          end
        end

        def home_item
          return unless allowed_to?(:show?, :dashboard)

          path = view_context.dashboard_path

          item(href: path, icon: "house", title: t(".dashboard"),
               current: current?(path))
        end

        # A run of catalog kinds, each with the number the user may read.
        def kind_section(name, scopes)
          kinds = nav_kinds(scopes)
          return if kinds.empty?

          SidebarSection(title: t(".#{name}")) do
            kinds.each do |kind|
              path = view_context.public_send(:"#{kind.plural}_path")

              item(href: path, icon: kind.default_icon,
                   title: kind.model.model_name.human(count: 2),
                   count: counts[kind.name], current: current?(path))
            end
          end
        end

        def explore_section
          SidebarSection(title: t(".explore")) do
            SOON.each do |key, icon_name|
              item(href: "#", icon: icon_name, title: t(".#{key}"),
                   badge: t(".soon"), disabled: true)
            end

            render_sidebar_links(self)
          end
        end

        # Kinds the current user may list, in the order given.
        #
        # @param scopes [Array<Symbol>] Kind scopes to consider.
        # @return [Array<Junction::Kind>] The kinds.
        def nav_kinds(scopes)
          scopes
            .filter_map { |scope| Junction::Kinds.by_scope(scope) }
            .select { |kind| allowed_to?(:index?, kind.model) }
        end

        # Every kind in the rail, in display order. The counts are fetched for
        # all of them at once, so they have to be known before any section
        # renders.
        #
        # @return [Array<Junction::Kind>] The kinds.
        def all_nav_kinds
          @all_nav_kinds ||= nav_kinds(NAV_SECTIONS.values.flatten)
        end

        # How many entities of each kind the user may read.
        #
        # Scoped the same way the listings are, so the number beside a link
        # matches what opening it shows. Computed once per request.
        #
        # @return [Hash{String => Integer}] Counts keyed by kind name.
        def counts
          @counts ||= Junction::ReadableEntities.current.counts(all_nav_kinds)
        end

        # Whether a rail row leads to the page being viewed.
        #
        # Compares paths rather than controllers so a nested page (eg. an
        # entity, its edit form) still lights up the listing it belongs to.
        #
        # @param path [String] The row's destination.
        # @return [Boolean] Whether the row is current.
        def current?(path)
          current = view_context.request.path

          current == path || current.start_with?("#{path}/")
        end

        def organization_name
          Junction.config.organization_name
        end

        def default_attrs
          {
            class: "relative z-20 w-66 shrink-0 flex flex-col " \
                   "bg-surface border-r border-border " \
                   "transition-[width] duration-300"
          }
        end
      end
    end
  end
end
