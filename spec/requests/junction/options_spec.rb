# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::OptionsController", type: :request do
  context "when the user is not authenticated" do
    describe "GET /options" do
      it_behaves_like "an action that requires authentication", :get, -> { options_path }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /options" do
      before { create(:api, api_type: "custom_api") }

      it_behaves_like "an action that requires permission",
        :get, -> { options_path }, %w[junction.codes/options.all.read]

      it "returns a successful response" do
        get options_path
        expect(response).to be_successful
      end

      it "renders the known options section" do
        get options_path
        expect(response.body).to include("Known options")
      end

      it "renders the other options section" do
        get options_path
        expect(response.body).to include("Other options")
      end

      it "renders chart titles" do
        get options_path
        expect(response.body).to include("Known vs Other Usage")
      end

      it "renders the top values chart title" do
        get options_path
        expect(response.body).to include("Top values")
      end

      it "renders arbitrary option values in the response" do
        get options_path
        expect(response.body).to include("custom_api")
      end
    end
  end
end
