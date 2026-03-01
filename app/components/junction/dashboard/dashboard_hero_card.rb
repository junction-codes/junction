# frozen_string_literal: true

module Junction
  module Components
    # Hero card component for user dashboard.
    class DashboardHeroCard < Base
      # Initializes the component.
      #
      # @param user [User] The current user.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(user:, **user_attrs)
        @user = user

        super(**user_attrs)
      end

      def view_template(&)
        Card(**attrs) do |card|
          card.header do |header|
            header.title(class: "text-2xl font-bold text-gray-900 dark:text-white") do
              t("dashboard.hero_card.welcome_title", name: @user.display_name)
            end

            header.description(class: "text-gray-600 dark:text-gray-400") do
              t("dashboard.hero_card.welcome_description", name: @user.display_name)
            end
          end

          card.content do
            div(class: "flex flex-col gap-4 md:flex-row md:items-center md:justify-between") do
              user_summary
              quick_actions
            end
          end
        end
      end

      private

      # Displays a summary of the current user.
      def user_summary
        div(class: "flex items-center gap-4") do
          UserAvatar(user: @user, size: :xl)

          div do
            h3(class: "text-lg font-semibold text-gray-900 dark:text-white") { @user.display_name }
            p(class: "text-sm text-gray-600 dark:text-gray-400") { @user.pronouns } if @user.pronouns.present?
            Link(href: "mailto:#{@user.email_address}", class: "p-0 ") do
              @user.email_address
            end
          end
        end
      end

      # Renders quick action buttons for the user.
      def quick_actions
        div(class: "flex flex-wrap gap-3") do
          Link(variant: :outline, href: user_path(@user)) do
            icon("user-round", class: "w-4 h-4 mr-2")
            plain t("dashboard.hero_card.view_profile")
          end

          Link(variant: :primary, href: new_component_path) do
            icon("server", class: "w-4 h-4 mr-2")
            plain t("dashboard.hero_card.new_component")
          end

          Link(variant: :secondary, href: new_system_path) do
            icon("network", class: "w-4 h-4 mr-2")
            plain t("dashboard.hero_card.new_system")
          end
        end
      end
    end
  end
end
