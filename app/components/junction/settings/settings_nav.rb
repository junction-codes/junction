# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # Settings navigation bar.
      #
      # Built from the same `settings_menu_item` registrations the account menu
      # renders. This allows plugins to define a settings page that gets added
      # automatically. It also handles access control, so we don't render menu
      # items that the user can't access.
      class SettingsNav < Base
        include Junction::PluginDispatchHelper

        def self.translation_path
          "junction.components.settings_nav"
        end

        ITEM = "-mb-px inline-flex items-center gap-2 pb-2 border-b-2 " \
               "border-transparent text-[13.5px] font-medium " \
               "text-text-tertiary hover:text-foreground hover:border-border"

        CURRENT = "border-accent-muted font-semibold text-foreground"

        def view_template
          items = plugin_settings_menu_items.sort_by { |item| item.fetch(:title) }
          return if items.empty?

          nav(**attrs, aria_label: t(".label")) do
            items.each { |item| nav_item(item) }
          end
        end

        private

        def default_attrs
          { class: "flex items-center gap-8 border-b border-border" }
        end

        # Renders a single navigation item.
        #
        # @param item [Hash<Symbol, String>] A settings menu item.
        # @option item [String] :href URL for the navigation item.
        # @option item [String] :title Title for the navigation item.
        def nav_item(item)
          href = item.fetch(:href)

          current = current?(href)

          a(href:, class: [ ITEM, (CURRENT if current) ].compact.join(" "),
            aria_current: ("page" if current)) do
            plain item.fetch(:title)
          end
        end

        # Whether a link points at the page being rendered.
        #
        # Compared the way the main navigation compares its own rows, so a
        # page nested under a settings path still lights up the entry it
        # belongs to.
        #
        # @param href [String] The item's path.
        # @return [Boolean]
        def current?(href)
          path = href.split("?").first
          current = view_context.request.path

          current == path || current.start_with?("#{path}/")
        end
      end
    end
  end
end
