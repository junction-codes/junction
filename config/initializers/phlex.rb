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
  Junction::Engine.root.join("app/components/junction"),
  namespace: Junction::Components
)

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/layouts/junction"),
  namespace: Junction::Layouts
)

Rails.autoloaders.main.push_dir(
  Junction::Engine.root.join("app/views/junction"),
  namespace: Junction::Views
)

# Eager-load all components so Phlex::Kit methods are available across group
# modules in lazy-load environments (development, test). Without this, Kit
# methods like ThemeToggle() are only defined after the class file is loaded,
# causing NoMethodError when called cross-group before that happens.
Rails.application.config.to_prepare do
  Rails.autoloaders.main.eager_load_dir(
    Junction::Engine.root.join("app/components/junction").to_s
  )
end
