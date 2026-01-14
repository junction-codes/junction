# frozen_string_literal: true

module Junction
  module Views
    # Base class for all Phlex views.
    class Base < ::Components::Base
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::URLFor
      include PluginDispatchHelper
    end
  end
end
