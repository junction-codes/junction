# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      class OpenPrStatCard < Base
        def template

          render ::Components::StatCard.new(
            title: "Open Pull Requests",
            value:,
            status:,
            icon: "git-pull-request-arrow"
          )
        end

        private

        def value
          @value ||= service.paged { service.pull_requests }.count
        end
      end
    end
  end
end
