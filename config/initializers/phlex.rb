# frozen_string_literal: true

require "phlex-rails"

module Junction
  module Components
    extend Phlex::Kit
  end

  module Layouts; end

  module Views; end
end


Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/components/junction"), namespace: Junction::Components
)

# Allow grouping components into subdirectories without creating a new
# namespace.
Rails.autoloaders.main.collapse(Junction::Engine.root.join("app/components/junction/*"))

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/layouts/junction"), namespace: Junction::Layouts
)

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/views/junction"), namespace: Junction::Views
)
