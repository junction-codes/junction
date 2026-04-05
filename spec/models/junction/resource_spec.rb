# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Resource, type: :model do
  subject(:resource) { build(:resource) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(resource).to be_valid
    end

    it_behaves_like "validates presence of", :title
    it_behaves_like "validates presence of", :resource_type
    it_behaves_like "validates uniqueness of", :name, "duplicate-slug", scope: :namespace
  end

  it_behaves_like "a sluggable entity"

  describe "associations" do
    it_behaves_like "a model with dependencies"
    it_behaves_like "a model that can be depended on"
    it_behaves_like "a model that can be owned"

    it { is_expected.to belong_to(:system) }
  end
end
