# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Turbo frame response for group member search results.
      class UserSearch < Views::Base
        # Initialize the view.
        #
        # @param results [Array<Junction::User>] The search results.
        def initialize(results:)
          @results = results
        end

        def view_template
          turbo_frame_tag "member-search-results" do
            if @results.empty?
              AutocompleteResultEmpty { t(".no_results") }
              next
            end

            AutocompleteResultList do
              @results.each do |user|
                AutocompleteResultItem(value: user.id.to_s, name: user.title) do
                  user.email_address
                end
              end
            end
          end
        end
      end
    end
  end
end
