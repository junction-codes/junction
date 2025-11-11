module RailJunction
  module Github
    class ApplicationController < ::ApplicationController
      private

      def client
        @client ||= ClientService.new(slug:)
      end

      def slug
        @object.annotations.fetch(Engine::ANNOTATION_PROJECT_SLUG, nil)
      end
    end
  end
end
