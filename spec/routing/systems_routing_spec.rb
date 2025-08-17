require "rails_helper"

RSpec.describe SystemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/systems").to route_to("systems#index")
    end

    it "routes to #new" do
      expect(get: "/systems/new").to route_to("systems#new")
    end

    it "routes to #show" do
      expect(get: "/systems/1").to route_to("systems#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/systems/1/edit").to route_to("systems#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/systems").to route_to("systems#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/systems/1").to route_to("systems#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/systems/1").to route_to("systems#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/systems/1").to route_to("systems#destroy", id: "1")
    end
  end
end
