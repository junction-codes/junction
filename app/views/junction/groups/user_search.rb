# frozen_string_literal: true

module Junction
  module Views
    module Groups
      # Turbo frame response for group member search results.
      class UserSearch < Views::Base
        # Initializes the view.
        #
        # @param results [Array<Junction::User>] The search results.
        def initialize(results:)
          @results = results
        end

        def view_template
          turbo_frame_tag "member-search-results" do
            if @results.empty?
              div(class: "border border-gray-200 dark:border-gray-600 rounded-md") do
                p(class: "px-3 py-4 text-sm text-gray-500 dark:text-gray-400 text-center") do
                  t(".no_results")
                end
              end
            else
              ul(role: "listbox", class: "border border-gray-200 dark:border-gray-600 " \
                                         "rounded-md overflow-hidden divide-y divide-gray-100 " \
                                         "dark:divide-gray-700") do
                @results.each do |user|
                  li(
                    role: "option",
                    tabindex: "-1",
                    data: {
                      action: "click->dependency-search#select",
                      dependency_search: {
                        target: "item",
                        value_param: user.id.to_s,
                        name_param: user.display_name
                      }
                    },
                    class: "flex items-center justify-between px-3 py-2 cursor-pointer " \
                           "hover:bg-gray-100 dark:hover:bg-gray-700 " \
                           "aria-selected:bg-gray-100 dark:aria-selected:bg-gray-700"
                  ) do
                    span(class: "text-sm font-medium text-gray-900 dark:text-white") { user.display_name }
                    span(class: "text-xs text-gray-500 dark:text-gray-400") { user.email_address }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
