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
              ResultEmpty { t(".no_results") }
              next
            end

            ResultList do |list|
              @results.each do |entity|
                list.item(
                  value: "#{entity.class.name}:#{entity.id}",
                  name: entity.title
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
