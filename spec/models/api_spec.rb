# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api, type: :model do
  subject(:api) { build(:api) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(api).to be_valid
    end

    it_behaves_like "validates presence of", :api_type
    it_behaves_like "validates presence of", :definition
    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :lifecycle
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name
    it_behaves_like "validates image_url format"
  end

  describe "associations" do
    it_behaves_like "a model with dependencies"
    it_behaves_like "a model that can be depended on"
    it_behaves_like "a model that can be owned"

    it { is_expected.to belong_to(:system) }
  end
end
