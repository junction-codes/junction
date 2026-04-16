# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::SystemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/systems").to route_to("junction/systems#index")
    end

    it "routes to #new" do
      expect(get: "/systems/new").to route_to("junction/systems#new")
    end

    it "routes to #show" do
      expect(get: "/systems/default/mysystem").to route_to("junction/systems#show", namespace: "default", name: "mysystem")
    end

    it "routes to #edit" do
      expect(get: "/systems/default/mysystem/edit").to route_to("junction/systems#edit", namespace: "default", name: "mysystem")
    end

    it "routes to #create" do
      expect(post: "/systems").to route_to("junction/systems#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/systems/default/mysystem").to route_to("junction/systems#update", namespace: "default", name: "mysystem")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/systems/default/mysystem").to route_to("junction/systems#update", namespace: "default", name: "mysystem")
    end

    it "routes to #destroy" do
      expect(delete: "/systems/default/mysystem").to route_to("junction/systems#destroy", namespace: "default", name: "mysystem")
    end
  end
end
