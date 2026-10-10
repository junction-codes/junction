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
      before { create(:api, type: "custom_api") }

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

      it "renders the undeclared options section" do
        get options_path
        expect(response.body).to include("In use, but not declared")
      end

      it "says how much of the field the YAML answers for" do
        get options_path
        expect(response.body).to match(/\d+% of records use a declared value/)
      end

      it "says where the options are declared" do
        get options_path
        expect(response.body).to include("config/catalog_options.yaml")
      end

      it "renders arbitrary option values in the response" do
        get options_path
        expect(response.body).to include("custom_api")
      end
    end
  end

  describe "the YAML snippet for an undeclared value" do
    before do
      sign_in_user_with_permissions(%w[junction.codes/options.all.read])
      create(:api, type: "custom_api")
      get options_path
    end

    it "keys it by the section the file uses" do
      expect(response.body).to include("apis:")
    end

    it "does not key it by the field name" do
      expect(response.body).not_to include("api_type:\n")
    end
  end
end
