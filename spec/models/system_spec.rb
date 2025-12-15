# frozen_string_literal: true

require "rails_helper"

RSpec.describe System, type: :model do
  subject(:system) { build(:system) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(system).to be_valid
    end

    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name
    it_behaves_like "validates image_url format"
    it_behaves_like "validates status inclusion"
  end

  describe "associations" do
    it_behaves_like "a model that can be owned"

    it { is_expected.to belong_to(:domain) }
    it { is_expected.to have_many(:components) }
    it { is_expected.to have_many(:resources) }
  end

  describe "defaults" do
    it_behaves_like "has default status active"
  end
end
