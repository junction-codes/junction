# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::GroupsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/groups").to route_to("junction/groups#index")
    end

    it "routes to #new" do
      expect(get: "/groups/new").to route_to("junction/groups#new")
    end

    it "routes to #show" do
      expect(get: "/groups/default/mygroup").to route_to("junction/groups#show", namespace: "default", name: "mygroup")
    end

    it "routes to #edit" do
      expect(get: "/groups/default/mygroup/edit").to route_to("junction/groups#edit", namespace: "default", name: "mygroup")
    end

    it "routes to #create" do
      expect(post: "/groups").to route_to("junction/groups#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/groups/default/mygroup").to route_to("junction/groups#update", namespace: "default", name: "mygroup")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/groups/default/mygroup").to route_to("junction/groups#update", namespace: "default", name: "mygroup")
    end

    it "routes to #destroy" do
      expect(delete: "/groups/default/mygroup").to route_to("junction/groups#destroy", namespace: "default", name: "mygroup")
    end
  end
end
