# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/robots.txt", type: :request do
  describe "GET /robots.txt" do
    before { get "/robots.txt" }

    it "responds with HTTP 200 OK" do
      expect(response).to have_http_status(:ok)
    end

    it "returns the exact contents of public/robots.txt" do
      expect(response.body).to eq(Junction::Engine.root.join("public", "robots.txt").read)
    end

    it "sets the correct content type" do
      expect(response.media_type).to eq("text/plain")
    end
  end
end
