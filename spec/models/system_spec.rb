# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System, type: :model do
  subject(:system) { build(:system) }

  it_behaves_like "a model that can be owned"

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(system).to be_valid
    end

    it 'is invalid without a name' do
      system.name = nil
      expect(system).not_to be_valid
      expect(system.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      create(:system, name: 'Duplicate System')
      system.name = 'Duplicate System'
      expect(system).not_to be_valid
      expect(system.errors[:name]).to include('has already been taken')
    end

    it 'is invalid without a description' do
      system.description = nil
      expect(system).not_to be_valid
      expect(system.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a status' do
      system.status = nil
      expect(system).not_to be_valid
      expect(system.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with a status other than active or closed' do
      system.status = 'pending'
      expect(system).not_to be_valid
      expect(system.errors[:status]).to include('is not included in the list')
    end

    it 'is valid with a blank image_url' do
      system.image_url = ''
      expect(system).to be_valid
    end

    it 'is invalid with an invalid image_url format' do
      system.image_url = 'not-a-valid-url'
      expect(system).not_to be_valid
      expect(system.errors[:image_url]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:domain) }
    it { is_expected.to have_many(:components) }
    it { is_expected.to have_many(:resources) }
  end

  describe 'defaults' do
    it 'defaults status to active' do
      expect(described_class.new.status).to eq('active')
    end
  end
end
