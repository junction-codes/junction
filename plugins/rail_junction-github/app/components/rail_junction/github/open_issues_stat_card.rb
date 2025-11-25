# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      class OpenIssuesStatCard < Base
        def template
          render ::Components::StatCard.new(
            title: "Open Issues",
            value:,
            status:,
            icon: "bug"
          )
        end

        private

        def value
          @value ||= service.repo.open_issues
        end
      end
    end
  end
end
