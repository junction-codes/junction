# frozen_string_literal: true

module RubyUI
  extend Phlex::Kit
end

module Layouts
end

# Allow using RubyUI instead RubyUi
Rails.autoloaders.main.inflector.inflect(
  "ruby_ui" => "RubyUI"
)

# Tell the autoloader where for find layours.
Rails.autoloaders.main.push_dir(
  Rails.root.join("app/layouts"), namespace: Layouts
)
Rails.autoloaders.main.collapse(Rails.root.join("app/layouts/*"))

# Allow grouping components into subdirectories without creating a new
# namespace.
Rails.autoloaders.main.collapse(Rails.root.join("app/components/*"))
