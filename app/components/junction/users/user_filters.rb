# frozen_string_literal: true

module Junction
  module Components
    # Renders filters available when searching User entities.
    class UserFilters < Base
      # Initializes the component.
      #
      # @param query [Ransack::Search] Ransack query object for filtering.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(query:, **user_attrs)
        @query = query

        super(**user_attrs)
      end

      def view_template(&)
        render Components::TableFilterBar.new(
          query: @query,
          action_url: users_path,
          clear_url: users_path
        ) do |bar|
          div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
            bar.text_filter(
              name: "q[display_name_or_email_address_cont]",
              label: "Search",
              placeholder: "Name or email address...",
              value: @query.display_name_or_email_address_cont
            )
          end

          div(class: "flex gap-2") do
            bar.actions
          end
        end
      end
    end
  end
end
