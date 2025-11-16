module RailJunction
  module Github
    class ApplicationController < ::ApplicationController
      private

      def slug
        @entity.annotations.fetch(Engine::ANNOTATION_PROJECT_SLUG, nil)
      end
    end
  end
end
