# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Api, type: :model do
  subject(:api) { build(:api) }

  it_behaves_like "a sluggable entity"

  describe "validations" do
    it_behaves_like "validates presence of", :api_type
    it_behaves_like "validates presence of", :definition
    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :lifecycle
    it_behaves_like "validates presence of", :title
    it_behaves_like "validates uniqueness of", :name, "duplicate-slug", scope: :namespace
    it_behaves_like "validates image_url format"

    it "is valid with valid attributes" do
      expect(api).to be_valid
    end
  end

  describe "associations" do
    it_behaves_like "a model with dependencies"
    it_behaves_like "a model that can be depended on"
    it_behaves_like "a model that can be owned"

    it { is_expected.to belong_to(:system) }
  end
end
