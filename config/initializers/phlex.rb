# frozen_string_literal: true

require "phlex-rails"

module Views
end

module Components
  extend Phlex::Kit
end

module Junction
  module Layouts; end

  module Views; end
end

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/views/junction"), namespace: Junction::Views
)

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/components"), namespace: Components
)

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/layouts"), namespace: Junction::Layouts
)
