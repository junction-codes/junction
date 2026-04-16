# frozen_string_literal: true

module Junction
  module Layouts
    class Base < Components::Base
      include Junction::Components
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::JavaScriptImportmapTags
      include Phlex::Rails::Helpers::StyleSheetLinkTag
      include Phlex::Rails::Helpers::TurboRefreshesWith

      private

      # Directives for search engines and link-preview style bots. Does not
      # control non-compliant crawlers; +/robots.txt+ states the same policy.
      CRAWLER_META_CONTENT =
        "noindex, nofollow, noarchive, nosnippet, noimageindex, notranslate, " \
        "max-image-preview:none, max-snippet:0, max-video-preview:0"

      def helpers
        @helpers ||= Junction::ApplicationController.helpers
      end

      # Renders the meta tags to block crawlers from indexing the site.
      def crawler_meta_tags
        meta name: "robots", content: CRAWLER_META_CONTENT
        meta name: "googlebot", content: CRAWLER_META_CONTENT
        meta name: "bingbot", content: CRAWLER_META_CONTENT
        meta name: "googlebot-news", content: "noindex, nofollow, noarchive, nosnippet"
        meta name: "applebot", content: CRAWLER_META_CONTENT
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
