# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Detail page for a Group.
      #
      # Rendering lives in {Entities::Show}; this adds what a group has of its
      # own: a contact address, the group above it, what it owns, and its
      # members.
      class Show < Entities::Show
        private

        def stat_cards
          StatCard(title: t(".stat_total_systems"),
                   value: @entity.systems.count, icon: "network")
          StatCard(title: t(".stat_total_components"),
                   value: @entity.components.count, icon: "server")
        end

        def plugin_slots
          super + [ :group_profile_cards ]
        end

        # Members are users rather than a kind the group is made of, and the
        # route is shaped differently, so this can't be a `detail_tabs` entry.
        def tab_triggers(list)
          super
          return unless can_view_members?

          tab_trigger(list, "members", t(".members"), @entity.members.count)
        end

        def tab_panes(tabs)
          super
          return unless can_view_members?

          pane(tabs, "members") do
            turbo_frame_tag "group_members",
                            src: junction_group_members_path(@entity),
                            loading: :lazy do
              div(class: "p-4") { Skeleton(class: "h-20") }
            end
          end
        end

        # Members are users, so seeing them takes permission to list users.
        #
        # @return [Boolean]
        def can_view_members?
          @options.fetch(:can_view_members, false)
        end
      end
    end
  end
end
