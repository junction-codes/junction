# frozen_string_literal: true

module Junction
  module Layouts
    class Base < Components::Base
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::JavaScriptImportmapTags
      include Phlex::Rails::Helpers::StyleSheetLinkTag
      include Phlex::Rails::Helpers::TurboRefreshesWith

      private

      def helpers
        @helpers ||= Junction::ApplicationController.helpers
      end

      # Returns the correct stylesheet asset name depending on whether we're in
      # the engine or the host application.
      #
      # @return [String] The stylesheet asset name.
      def stylesheet_asset
        Rails.root == Junction::Engine.root ? "builds/tailwind" : "tailwind"
      end
    end
  end
end
