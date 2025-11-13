# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      extend Phlex::Kit
    end

    module Views
    end
  end
end

Rails.autoloaders.main.push_dir(
  RailJunction::Github::Engine.root.join("app/views/rail_junction/github"),
  namespace: RailJunction::Github::Views
)

Rails.autoloaders.main.push_dir(
  RailJunction::Github::Engine.root.join("app/components/rail_junction/github"),
  namespace: RailJunction::Github::Components
)
