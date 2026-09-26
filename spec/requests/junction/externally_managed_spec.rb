# frozen_string_literal: true

require "rails_helper"

RSpec.describe "An externally managed entity", type: :request do
  let(:component) do
    create(:component, title: "Payments API", managed_by: "location",
                       source_ref: "junction.yaml")
  end

  before do
    user = create_user_with_permissions(%w[junction.codes/components.all.read
                                           junction.codes/components.all.write])
    sign_in(user:, password: "Password1!")
  end

  describe "its form" do
    before { get edit_component_path(component) }

    it "opens" do
      expect(response).to have_http_status(:ok)
    end

    it "says where the entity comes from" do
      expect(response.body).to include("comes from a Location")
    end

    it "names the file it came from" do
      expect(response.body).to include("junction.yaml")
    end

    it "disables every field at once" do
      expect(response.parsed_body.at_css("form fieldset[disabled]")).to be_present
    end

    it "offers nothing to save" do
      expect(response.parsed_body.at_css("form button[type='submit']")).to be_nil
    end
  end

  describe "saving it anyway" do
    before do
      patch component_path(component), params: { component: { title: "Renamed" } }
    end

    it "is refused" do
      expect(response).to have_http_status(:see_other)
    end

    it "says so" do
      expect(flash[:alert]).to include("not authorized")
    end

    it "leaves the entity alone" do
      expect(component.reload.title).to eq("Payments API")
    end
  end

  describe "an entity of our own" do
    let(:component) { create(:component, title: "Payments API") }

    before { get edit_component_path(component) }

    it "has no banner" do
      expect(response.body).not_to include("Read-only")
    end

    it "can be saved" do
      expect(response.parsed_body.at_css("form button[type='submit']")).to be_present
    end
  end
end
