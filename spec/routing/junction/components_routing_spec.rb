# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::ComponentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/components").to route_to("junction/components#index")
    end

    it "routes to #new" do
      expect(get: "/components/new").to route_to("junction/components#new")
    end

    it "routes to #show" do
      expect(get: "/components/default/mycomponent").to route_to(
        "junction/components#show",
        namespace: "default",
        name: "mycomponent",
        catalog_scope: "component"
      )
    end

    it "routes to #edit" do
      expect(get: "/components/default/mycomponent/edit").to route_to(
        "junction/components#edit",
        namespace: "default",
        name: "mycomponent",
        catalog_scope: "component"
      )
    end

    it "routes to #create" do
      expect(post: "/components").to route_to("junction/components#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/components/default/mycomponent").to route_to(
        "junction/components#update",
        namespace: "default",
        name: "mycomponent",
        catalog_scope: "component"
      )
    end

    it "routes to #update via PATCH" do
      expect(patch: "/components/default/mycomponent").to route_to(
        "junction/components#update",
        namespace: "default",
        name: "mycomponent",
        catalog_scope: "component"
      )
    end

    it "routes to #destroy" do
      expect(delete: "/components/default/mycomponent").to route_to(
        "junction/components#destroy",
        namespace: "default",
        name: "mycomponent",
        catalog_scope: "component"
      )
    end
  end
end
