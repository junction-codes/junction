# frozen_string_literal: true

module Junction
  module Views
    module Roles
      # Renders the permission editor for one role.
      #
      # The page keeps the settings sub-nav but drops the index-and-detail
      # shape the other settings pages use.
      class Edit < Views::Base
        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param role [Junction::Role] The role being edited.
        # @param available_permissions [Array<Junction::Permission>] Every
        #   permission that may be granted.
        # @param reach [Hash] The number of entities that hold the role.
        # @option reach [Integer] :groups The number of groups holding the role.
        # @option reach [Integer] :people The number of people holding the role.
        # @param submitted [Array<String>] The permissions a rejected save
        #   sent, which are selected in place of the ones the role holds.
        # @param can_destroy [Boolean] Whether the role may be deleted.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        def initialize(role:, available_permissions:, reach: {},
                       submitted: nil, can_destroy: false, breadcrumbs: [])
          @role = role
          @available_permissions = available_permissions
          @reach = reach
          @submitted = submitted
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            SettingsPage(title: heading, chip:, description:) do
              RoleForm(role: @role, available_permissions: @available_permissions,
                       reach: @reach, submitted: @submitted,
                       can_destroy: @can_destroy)
            end
          end
        end

        private

        # Returns the heading, naming the role as it's stored.
        #
        # A rejected save re-renders this page with what the user typed still
        # in the record, so the title they cleared would leave the page with no
        # heading at all.
        #
        # @return [String] The heading.
        def heading
          @role.title_was.presence || @role.title
        end

        # Returns the page description.
        #
        # @return [String] The description.
        def description
          t(@role.system? ? ".system_description" : ".description")
        end

        # Returns the label for the chip displayed beside the page title.
        #
        # @return [String] The label.
        def chip
          t(@role.system? ? ".system_role" : ".custom_role")
        end
      end
    end
  end
end
