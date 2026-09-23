# frozen_string_literal: true

module Junction
  module Views
    module Users
      # Detail page for a User.
      #
      # Rendering lives in {Entities::Show}. This adds what a person has of
      # their own: pronouns in place of a description, and counts of what they
      # belong to.
      class Show < Entities::Show
        private

        # People have no description; their pronouns take its place, as they
        # do in previews.
        def summary
          @entity.pronouns
        end

        def stat_cards
          StatCard(title: t(".stat_total_groups"),
                   value: @entity.group_memberships.count, icon: "users-round")
          StatCard(title: t(".stat_total_systems"),
                   value: @entity.systems.count, icon: "network")
          StatCard(title: t(".stat_total_components"),
                   value: @entity.components.count, icon: "server")
        end

        def plugin_slots
          super + [ :user_profile_cards ]
        end
      end
    end
  end
end
