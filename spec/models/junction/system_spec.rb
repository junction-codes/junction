# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::System, type: :model do
  subject(:system) { build(:system) }

  it_behaves_like "a sluggable entity"

  describe "validations" do
    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :type
    it_behaves_like "validates presence of", :title
    it_behaves_like "validates uniqueness of", :name, "duplicate-slug", scope: :namespace
    it_behaves_like "validates image_url format"

    it "is valid with valid attributes" do
      expect(system).to be_valid
    end

    it "accepts arbitrary type values" do
      system.type = "monolith"

      expect(system).to be_valid
    end
  end

  describe "#icon" do
    it "uses the catalog icon for a known system type" do
      allow(Junction::CatalogOptions).to receive(:systems).and_return(
        { "service" => { icon: "server" } }.with_indifferent_access
      )

      expect(build(:system, type: "service").icon).to eq("server")
    end

    it "falls back to the default icon for an unknown system type" do
      expect(build(:system, type: "monolith").icon).to eq("network")
    end
  end

  describe "associations" do
    it_behaves_like "a model that can be owned"

    it { is_expected.to belong_to(:domain) }
    it { is_expected.to have_many(:components) }
    it { is_expected.to have_many(:resources) }
  end
end
