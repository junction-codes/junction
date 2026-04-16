# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::RobotsController, type: :routing do
  describe "routing" do
    it "routes robots.txt to #show" do
      expect(get: "/robots.txt").to route_to("junction/robots#show")
    end
  end
end
