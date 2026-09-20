# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Ownership information for an entity.
      class EntityOwnershipCard < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity [Junction::Entity] An ownable entity.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity:, **user_attrs)
          @entity = entity

          super(**user_attrs)
        end

        def view_template
          EntityCard(title: t(".title"), **attrs) do
            div(class: "flex items-center gap-2.5 min-w-0") do
              KindChip(entity: owner)

              div(class: "min-w-0") do
                div(class: "text-[13px] font-semibold text-foreground truncate") do
                  EntityLink(entity: owner, class: "text-foreground")
                end
                detail
              end
            end
          end
        end

        private

        # Details about the owner, if the current user is allowed to see them.
        #
        # For a group, how many members it has and where it sits. For a person,
        # their contact information.
        def detail
          return unless allowed_to?(:show?, owner)

          text = owner.is_a?(Junction::User) ? owner.email : group_detail
          return if text.blank?

          div(class: "text-[11.5px] text-muted-foreground truncate") { text }
        end

        # Details about the group that owns the entity.
        #
        # @return [String] Group details.
        def group_detail
          [
            t(".members", count: owner.members.count),
            owner.parent&.title
          ].compact.join(" · ")
        end

        # The owner of the entity.
        #
        # @return [Junction::User, Junction::Group] The owner.
        def owner
          @entity.owner
        end

        # The model class for the entity.
        #
        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end
      end
    end
  end
end
