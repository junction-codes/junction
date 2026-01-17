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
      expect(get: "/components/1").to route_to("junction/components#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/components/1/edit").to route_to("junction/components#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/components").to route_to("junction/components#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/components/1").to route_to("junction/components#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/components/1").to route_to("junction/components#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/components/1").to route_to("junction/components#destroy", id: "1")
    end
  end
end
