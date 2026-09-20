# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Sluggable do
  describe "#entity_ref" do
    it "joins the kind, namespace and name" do
      component = build(:component, namespace: "acme", name: "payments-api")

      expect(component.entity_ref).to eq("component:acme/payments-api")
    end

    it "lowercases the kind" do
      api = build(:api, namespace: "default", name: "billing")

      expect(api.entity_ref).to eq("api:default/billing")
    end
  end
end
