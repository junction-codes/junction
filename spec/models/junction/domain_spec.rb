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

    it do
      expect(domain).to have_many(:children).class_name("Junction::Domain")
                                            .with_foreign_key("parent_id")
                                            .dependent(:destroy)
    end

    it do
      expect(domain).to belong_to(:parent).class_name("Junction::Domain")
                                          .optional
    end

    it { is_expected.to have_many(:systems) }
  end

  describe "parent validations" do
    it "rejects assigning the domain as its own parent" do
      domain = create(:domain)
      domain.parent = domain

      expect(domain).not_to be_valid
    end

    it "allows a parent in a different namespace" do
      parent = create(:domain, namespace: "other")
      domain = build(:domain, parent: parent, namespace: "default")

      expect(domain).to be_valid
    end

    it "rejects assigning a descendant as parent" do
      parent = create(:domain)
      child = create(:domain, parent: parent)
      parent.parent = child

      expect(parent).not_to be_valid
    end
  end

  describe "#descendant_ids" do
    it "returns an empty array for a domain with no children" do
      domain = create(:domain)

      expect(domain.descendant_ids).to eq([])
    end

    it "returns direct and nested child ids" do
      parent = create(:domain)
      child = create(:domain, parent: parent)
      grandchild = create(:domain, parent: child)

      expect(parent.descendant_ids).to contain_exactly(child.id, grandchild.id)
    end
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
