# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Renders one role in the roles page's detail pane.
      #
      # The groups matter as much as the permissions. Changing a role changes
      # what every group pointing at it can do, so the list of groups is on
      # the same page as the permission set.
      class Show < Views::Base
        include Phlex::Rails::Helpers::TimeAgoInWords

        # Initializes the view.
        #
        # @param detail [Hash] The role and its details from
        #   {Junction::Roles::Overview#detail}.
        # @param can_edit [Boolean] Whether the user may change it.
        def initialize(detail:, can_edit: false)
          @detail = detail
          @role = detail.fetch(:role)
          @can_edit = can_edit
        end

        def view_template
          turbo_frame_tag "role_#{@detail.fetch(:id)}" do
            div(class: "space-y-6") do
              header
              permissions
              granted_to
            end
          end
        end

        private

        # Renders the header for the role.
        def header
          div(class: "flex items-start justify-between gap-4") do
            SettingsDetailHeader(title: @role.title, mono: false,
                                 badge: kind_badge,
                                 description: @role.description) do
              timestamps
            end

            edit_action
          end
        end

        # Builds the badge indicating the role's origin.
        #
        # @return [Hash] Whether the role ships with the app or was defined
        #   here, which is also whether it can be edited.
        def kind_badge
          { label: t(@role.system? ? ".system" : ".custom"), variant: :outline }
        end

        # Renders the edit button, unless the role is a system role.
        def edit_action
          return unless @can_edit && !@role.system?

          Link(href: junction_edit_catalog_path(@role), variant: :outline,
               class: "shrink-0 border-border bg-surface shadow-none " \
                      "text-[13.5px] text-text-strong gap-2") do
            icon("pencil", class: "w-4 h-4")
            plain t(".edit")
          end
        end

        # Renders when the role was created and when it last changed.
        def timestamps
          p(class: "mt-2 text-[12px] text-text-tertiary") do
            t(".timestamps",
              created: @role.created_at.to_date.to_formatted_s(:long),
              updated: time_ago_in_words(@role.updated_at))
          end
        end

        # Renders the permission matrix.
        def permissions
          rows = @detail.fetch(:matrix)

          section(class: "space-y-3") do
            div do
              h3(class: "text-[14px] font-semibold text-foreground") do
                t(".permissions")
              end
              p(class: "text-[12.5px] text-text-tertiary") { permissions_summary }
            end

            next p(class: "text-sm text-text-tertiary") { t(".no_permissions") } if rows.empty?

            RolePermissionMatrix(rows:)
          end
        end

        # Builds the summary under the Permissions heading.
        #
        # @return [String] The summary.
        def permissions_summary
          t(".permissions_summary", count: @detail.fetch(:permissions).size,
                                    total: registered_total)
        end

        # Counts every permission registered on this instance.
        #
        # @return [Integer] The count.
        def registered_total
          Junction::PluginRegistry.permissions.size
        end

        # Renders the groups granted this role.
        #
        # The count is larger than the groups' own membership. A role granted to
        # a group also reaches the groups beneath it.
        def granted_to
          groups = @detail.fetch(:groups)

          section(class: "space-y-3 border-t border-border pt-5") do
            div do
              h3(class: "text-[14px] font-semibold text-foreground") do
                t(".granted_to")
              end
              p(class: "font-mono text-[11.5px] text-text-tertiary") do
                t(".granted_directly")
              end
            end

            next p(class: "text-sm text-text-tertiary") { t(".no_groups") } if groups.empty?

            group_cards(groups)

            p(class: "text-[12.5px] text-text-tertiary") do
              t(".effective_people", count: @detail.fetch(:people))
            end
          end
        end

        # Renders the groups holding the role, as a grid of cards.
        #
        # @param groups [Array<Hash>] The groups and their member counts.
        def group_cards(groups)
          div(class: "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3") do
            groups.each { |granted| group_card(granted) }
          end
        end

        # Renders one group as a card linking to the group itself.
        #
        # @param granted [Hash] The group and how many members it has.
        def group_card(granted)
          group = granted.fetch(:group)

          Link(href: junction_catalog_path(group),
               class: "group flex items-center gap-3 rounded-lg border " \
                      "border-border bg-background px-3.5 py-3 no-underline " \
                      "hover:no-underline hover:border-line-strong") do
            icon(group.icon, fallback: Junction::Kind::DEFAULT_ICON,
                 class: "shrink-0 w-4 h-4 text-kind-group-fg")

            span(class: "min-w-0 flex flex-col") do
              span(class: "truncate text-[13px] font-medium text-text-strong " \
                          "underline-offset-2 group-hover:underline") do
                group.title
              end
              span(class: "text-[11.5px] text-text-tertiary") do
                t(".member_count", count: granted.fetch(:members))
              end
            end
          end
        end
      end
    end
  end
end
