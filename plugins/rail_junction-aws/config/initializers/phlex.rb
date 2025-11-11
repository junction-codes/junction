# frozen_string_literal: true

module RailJunction
  module Aws
    module Components
      extend Phlex::Kit
    end

    module Views
    end
  end
end

Rails.autoloaders.main.push_dir(
  RailJunction::Aws::Engine.root.join("app/views/rail_junction/aws"),
  namespace: RailJunction::Aws::Views
)

Rails.autoloaders.main.push_dir(
  RailJunction::Aws::Engine.root.join("app/components/rail_junction/aws"),
  namespace: RailJunction::Aws::Components
)
