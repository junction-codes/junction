# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deployment, type: :model do
  describe 'validations' do
    subject(:deployment) { build(:deployment) }

    it 'is valid with valid attributes' do
      expect(deployment).to be_valid
    end

    it 'is invalid without a platform' do
      deployment.platform = nil
      expect(deployment).not_to be_valid
      expect(deployment.errors[:platform]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:component) }
  end
end
