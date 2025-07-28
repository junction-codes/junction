# frozen_string_literal: true

module Layouts
  class Base < Components::Base
    include Phlex::Rails::Helpers::CSPMetaTag
    include Phlex::Rails::Helpers::CSRFMetaTags
    include Phlex::Rails::Helpers::Flash
    include Phlex::Rails::Helpers::JavaScriptImportmapTags
    include Phlex::Rails::Helpers::StyleSheetLinkTag
    include Phlex::Rails::Helpers::TurboRefreshMethodTag
    include Phlex::Rails::Helpers::TurboRefreshScrollTag
  end
end
