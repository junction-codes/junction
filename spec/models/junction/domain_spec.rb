# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Domain, type: :model do
  subject(:domain) { build(:domain) }

  it_behaves_like "a sluggable entity"

  describe "validations" do
    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :domain_type
    it_behaves_like "validates presence of", :title
    it_behaves_like "validates uniqueness of", :name, "duplicate-slug", scope: :namespace
    it_behaves_like "validates status inclusion"
    it_behaves_like "validates image_url format"

    it "is valid with valid attributes" do
      expect(domain).to be_valid
    end
  end

  describe "associations" do
    it_behaves_like "a model that can be owned"

    it { is_expected.to have_many(:systems) }
  end

  describe "defaults" do
    it_behaves_like "has default status active"
  end

  describe "#icon" do
    it "returns the icon for a known domain type" do
      allow(Junction::CatalogOptions).to receive(:domains).and_return(
        { "product-area" => { icon: "box" } }
      )
      domain = build(:domain, domain_type: "product-area")

      expect(domain.icon).to eq("box")
    end

    it "returns the fallback icon for an unknown domain type" do
      allow(Junction::CatalogOptions).to receive(:domains).and_return({})
      domain = build(:domain, domain_type: "unknown-type")

      expect(domain.icon).to eq("briefcase")
    end
  end
end
