  # frozen_string_literal: true

  module Layouts
    class Base < Components::Base
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::StyleSheetLinkTag
      include Phlex::Rails::Helpers::JavaScriptImportmapTags

      private

      def helpers
        @helpers ||= Junction::ApplicationController.helpers
      end
    end
  end
# end
