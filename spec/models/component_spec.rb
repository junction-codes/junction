# frozen_string_literal: true

require "rails_helper"

RSpec.describe Component, type: :model do
  subject(:component) { build(:component) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(component).to be_valid
    end

    it_behaves_like "validates presence of", :component_type
    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :lifecycle
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name
    it_behaves_like "validates image_url format"

    it "is invalid with an unknown component_type" do
      component.component_type = "invalid_type"
      expect(component).not_to be_valid
    end

    it "is invalid with an unknown lifecycle" do
      component.lifecycle = "invalid_lifecycle"
      expect(component).not_to be_valid
    end
  end

  describe "associations" do
    it_behaves_like "a model that can be depended on"
    it_behaves_like "a model that can be owned"
    it_behaves_like "a model with dependencies"

    it { is_expected.to have_many(:deployments).dependent(:destroy) }
    it { is_expected.to belong_to(:system).optional }
  end

  describe "defaults" do
    it 'defaults lifecycle to "experimental" on new instances' do
      new_component = described_class.new
      expect(new_component.lifecycle).to eq("experimental")
    end
  end

  describe "#icon" do
    before do
      allow(CatalogOptions).to receive(:kinds).and_return(
        {
          "service" => { icon: "cloud" },
          "library" => {}
        }.with_indifferent_access
      )
    end

    context "when component type has a defined icon" do
      it "returns the specific icon" do
        component.component_type = "service"
        expect(component.icon).to eq("cloud")
      end
    end

    context "when component type does not have a defined icon" do
      it "returns the default icon" do
        component.component_type = "library"
        expect(component.icon).to eq("server")
      end
    end

    context "when component type is not in the catalog" do
      it "returns the default icon" do
        component.component_type = "unknown_type"
        expect(component.icon).to eq("server")
      end
    end
  end
end
