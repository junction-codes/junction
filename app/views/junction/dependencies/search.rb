# frozen_string_literal: true

module Junction
  module Views
    module Dependencies
      # Turbo frame response for dependency search results.
      class Search < Views::Base
        # Initialize the view.
        #
        # @param results [Array<ApplicationRecord>] The search results.
        def initialize(results:)
          @results = results
        end

        def view_template
          turbo_frame_tag "dependency-search-results" do
            if @results.empty?
              AutocompleteResultEmpty { t(".no_results") }
              next
            end

            AutocompleteResultList do
              @results.each do |entity|
                AutocompleteResultItem(
                  value: "#{entity.class.name}:#{entity.id}",
                  name: entity.name
                ) do
                  "#{entity.class.name.demodulize.downcase} · #{entity.type}"
                end
              end
            end
          end
        end
      end
    end
  end
end
