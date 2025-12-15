# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain, type: :model do
  subject(:domain) { build(:domain) }

  it_behaves_like "a model that can be owned"

  describe "validations" do
    it "is valid with valid attributes" do
      expect(domain).to be_valid
    end

    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name
    it_behaves_like "validates status inclusion"
    it_behaves_like "validates image_url format"
  end

  describe "associations" do
    it { is_expected.to have_many(:systems) }
  end

  describe "defaults" do
    it_behaves_like "has default status active"
  end
end
