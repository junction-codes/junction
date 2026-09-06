# frozen_string_literal: true

module Junction
  module Components
    module Group
      # Create and edit form for a Group.
      #
      # The fields come from `Junction::Group.form_fields` and the rendering
      # from {Entity::EntityForm}. Groups add the role grants, which is the one
      # section no other kind has.
      class GroupForm < Entity::EntityForm
        private

        # Renders the role grants, when the current user may change them.
        #
        # `available_roles` is nil for anyone without write access to roles, so
        # the section is absent rather than disabled -- editing a group must not
        # be a way to hand it a permission set.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def extra_sections(form)
          available_roles = @options[:available_roles]
          return if available_roles.nil?

          Card do |card|
            card.header do |header|
              header.title { t(".roles_title") }
              header.description { t(".roles_description") }
            end

            card.content do
              render Field::Roles.new(form, :role_ids, available_roles:, label: "")
            end
          end
        end
      end
    end
  end
end
