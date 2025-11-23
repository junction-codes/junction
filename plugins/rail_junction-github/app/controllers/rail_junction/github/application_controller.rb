module RailJunction
  module Github
    class ApplicationController < ::ApplicationController
      private

      # Look up the context for the current request based on the parameters.
      #
      # @return [Class<ApplicationRecord>] The context class.
      #
      # @raise [ActiveRecord::RecordNotFound] If the context class is not found
      #   or is invalid.
      def context
        name = entity_key.to_s.sub(/_id\z/, '')
        context = name.classify.safe_constantize
        raise ActiveRecord::RecordNotFound, "Unknown entity #{name}" unless context && context < ::ApplicationRecord

        context
      end

      # Key for the entity in the parameters.
      #
      # @return [String] The parameter key.
      #
      # @raise [ActionController::BadRequest] If no id parameter is found.
      def entity_key
        key = params.keys.find { |k| k.to_s.end_with?('_id') }
        raise ActionController::BadRequest, 'Missing id parameter' unless key

        key
      end

      # Build a Turbo frame ID based on the entity type.
      #
      # @param suffix [String] The suffix to append to the entity type.
      # @return [String] The Turbo frame ID.
      def frame_id(suffix)
        "#{entity_key.to_s.sub(/_id\z/, '')}-#{suffix}"
      end

      # Set the current entity based on the current context.
      def set_entity
        @entity = context.find(params[entity_key])
      end

      def slug
        @entity.annotations.fetch(Engine::ANNOTATION_PROJECT_SLUG, nil)
      end
    end
  end
end
