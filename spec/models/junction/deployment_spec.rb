# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Deployment, type: :model do
  subject(:deployment) { build(:deployment) }

  describe "validations" do
    it 'is valid with valid attributes' do
      expect(deployment).to be_valid
    end

    it_behaves_like "validates presence of", :environment
    it_behaves_like "validates presence of", :platform
  end

  describe "associations" do
    it { is_expected.to belong_to(:component) }
  end
end
