require "rails_helper"

RSpec.describe DeploymentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/deployments").to route_to("deployments#index")
    end

    it "routes to #new" do
      expect(get: "/deployments/new").to route_to("deployments#new")
    end

    it "routes to #show" do
      expect(get: "/deployments/1").to route_to("deployments#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/deployments/1/edit").to route_to("deployments#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/deployments").to route_to("deployments#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/deployments/1").to route_to("deployments#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/deployments/1").to route_to("deployments#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/deployments/1").to route_to("deployments#destroy", id: "1")
    end
  end
end
