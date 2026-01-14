# frozen_string_literal: true

module Junction
  module Views
    module Dashboards
      # Personalized dashboard for authenticated users.
      #
      # @todo Make the dashboard more dynamic and configurable.
      class Show < Views::Base
        attr_reader :user

        # Initialize the view.
        #
        # @param user [User] The current user.
        # @param owned_entities [Array<ApplicationRecord>] List of catalog entities
        #   owned by the current user.
        # @param recent_catalog_items [Array<ApplicationRecord>] List of recently
        #   updated catalog entities.
        def initialize(user:, owned_entities:, recent_catalog_items:)
          @user = user
          @owned_entities = owned_entities
          @recent_catalog_items = recent_catalog_items
        end

        def view_template
          render Junction::Layouts::Application.new do
            div(class: "p-6 space-y-8") do
              ::Components::DashboardHeroCard(user:)

              render_plugin_ui_components(context: @user, slot: :user_dashboard)

              div(class: "grid grid-cols-1 xl:grid-cols-3 gap-6") do
                ::Components::DashboardMyEntities(entities: @owned_entities)
                ::Components::DashboardUpdatedEntities(entities: @recent_catalog_items)
              end
            end
          end
        end
      end
    end
  end
end
