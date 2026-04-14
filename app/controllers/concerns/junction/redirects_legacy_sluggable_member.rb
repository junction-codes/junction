# frozen_string_literal: true

module Junction
  # Redirects `/…/:numeric_id` (and nested paths) to canonical `/…/:namespace/:name` URLs.
  module RedirectsLegacySluggableMember
    extend ActiveSupport::Concern

    included do
      skip_verify_authorized only: :redirect_sluggable_from_numeric_id if respond_to?(:skip_verify_authorized, true)
    end

    class_methods do
      # @param path_prefix [String] e.g. "/components"
      # @param model [Class<ActiveRecord::Base>] catalog model class
      def redirects_legacy_sluggable(path_prefix, model)
        @legacy_sluggable_path_prefix = path_prefix.freeze
        @legacy_sluggable_model = model
      end

      def legacy_sluggable_path_prefix
        @legacy_sluggable_path_prefix
      end

      def legacy_sluggable_model
        @legacy_sluggable_model
      end
    end

    def redirect_sluggable_from_numeric_id
      record = self.class.legacy_sluggable_model.find(params.expect(:id))
      suffix = legacy_sluggable_redirect_suffix
      target = polymorphic_path(record) + suffix
      target += "?#{request.query_string}" if request.query_string.present?
      redirect_to target, status: legacy_sluggable_redirect_status, allow_other_host: false
    end

    private

    def legacy_sluggable_redirect_suffix
      prefix = self.class.legacy_sluggable_path_prefix
      id_segment = "/#{params.expect(:id)}"
      tail = request.path.sub(/\A#{Regexp.escape(prefix)}#{Regexp.escape(id_segment)}/, "")
      tail = tail.delete_prefix("/")
      tail.present? ? "/#{tail}" : ""
    end

    def legacy_sluggable_redirect_status
      request.get? || request.head? ? :moved_permanently : :permanent_redirect
    end
  end
end
