# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Domain, type: :model do
  subject(:domain) { build(:domain) }

  it_behaves_like "a sluggable entity"

  describe "validations" do
    it_behaves_like "validates presence of", :description
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
end
