# frozen_string_literal: true

module Junction
  module Components
    module Sidebar
      # The account menu in the rail footer.
      class AccountMenu < Base
        # Initializes a new component.
        #
        # @param user [Junction::User] The signed-in user.
        # @param settings_items [Array<Hash>] Resolved settings menu items the
        #   user is allowed to see.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(user:, settings_items: [], **user_attrs)
          @user = user
          @settings_items = settings_items

          super(**user_attrs)
        end

        def view_template
          div(**attrs) do
            DropdownMenu(options: { placement: "top-start",
                                    strategy: "fixed" }) do |menu|
              menu.trigger(class: "w-full") { |trigger| render_trigger(trigger) }
              menu.content(class: "w-70") { |content| render_content(content) }
            end
          end
        end

        private

        def render_trigger(trigger)
          trigger.button(variant: :ghost,
                         aria_label: t(".trigger"),
                         class: "w-full h-auto justify-start px-2 py-2") do
            UserAvatar(user: @user, class: "w-8 h-8 shrink-0")

            span(data_sidebar_target: "linkText",
                 class: "ml-2.5 min-w-0 flex flex-col items-start") do
              span(class: "text-[13px] font-medium text-text-strong truncate") do
                @user.title
              end
              span(class: "text-[11px] text-muted-foreground truncate") do
                @user.email
              end
            end

            span(data_sidebar_target: "linkText", class: "ml-auto") do
              icon("chevron-up", class: "w-4 h-4 text-muted-foreground")
            end
          end
        end

        def render_content(content)
          render_header
          content.separator

          content.label { t(".account") }
          content.item(href: junction_catalog_path(@user)) do
            icon("user-round", class: "w-4 h-4 mr-2")
            plain t(".profile")
          end
          content.item(href: groups_path) do
            icon("users-round", class: "w-4 h-4 mr-2")
            plain t(".groups")
            menu_meta(@user.groups.size)
          end

          render_settings(content)

          content.separator
          render_theme_row
          content.separator
          render_sign_out(content)
        end

        # The user the menu belongs to, so the popover names itself.
        def render_header
          div(class: "flex items-center gap-2.5 px-2 py-2") do
            UserAvatar(user: @user, class: "w-9 h-9 shrink-0")

            div(class: "min-w-0") do
              p(class: "text-[13.5px] font-medium text-foreground truncate") do
                @user.title
              end
              p(class: "text-[11.5px] text-muted-foreground truncate") do
                @user.email
              end
            end
          end
        end

        # The settings pages, if this user may open any of them.
        def render_settings(content)
          return if @settings_items.empty?

          content.separator
          content.label(class: "flex items-baseline justify-between") do
            plain t(".junction")
            span(class: "text-[10.5px] font-normal normal-case " \
                        "text-line-strong") { t(".instance_settings") }
          end

          @settings_items.each do |item|
            content.item(href: item[:href]) do
              icon(item[:icon], fallback: Junction::Kind::DEFAULT_ICON,
                   class: "w-4 h-4 mr-2")
              plain item[:title]
            end
          end
        end

        def render_theme_row
          div(class: "flex items-center justify-between px-2 py-1.5") do
            span(class: "text-sm") { t(".theme") }
            ThemeToggle()
          end
        end

        def render_sign_out(content)
          content.item(href: session_path, data_turbo_method: :delete,
                       class: "text-destructive") do
            icon("log-out", class: "w-4 h-4 mr-2")
            plain t(".sign_out")
          end
        end

        # Renders the number beside a menu row.
        def menu_meta(value)
          span(class: "ml-auto text-[11px] tabular-nums " \
                      "text-muted-foreground") { value.to_s }
        end

        def default_attrs
          { class: "mt-auto px-2 pb-3 pt-2 border-t border-border" }
        end
      end
    end
  end
end
