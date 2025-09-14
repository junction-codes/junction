module RailJunction
  module Github
    class ApplicationController < ::ApplicationController
      private

      def client
        @client ||= ClientService.from_url(@object.repository_url)
      end
    end
  end
end
