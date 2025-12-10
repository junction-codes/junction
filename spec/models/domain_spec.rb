# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Domain, type: :model do
  subject(:domain) { build(:domain) }

  it_behaves_like "a model that can be owned"

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(domain).to be_valid
    end

    it 'is invalid without a name' do
      domain.name = nil
      expect(domain).not_to be_valid
      expect(domain.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      create(:domain, name: 'Duplicate Name')
      domain.name = 'Duplicate Name'
      expect(domain).not_to be_valid
      expect(domain.errors[:name]).to include('has already been taken')
    end

    it 'is invalid without a description' do
      domain.description = nil
      expect(domain).not_to be_valid
      expect(domain.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a status' do
      domain.status = nil
      expect(domain).not_to be_valid
      expect(domain.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with a status other than active or closed' do
      domain.status = 'pending'
      expect(domain).not_to be_valid
      expect(domain.errors[:status]).to include('is not included in the list')
    end

    it 'is valid with a blank image_url' do
      domain.image_url = ''
      expect(domain).to be_valid
    end

    it 'is invalid with an invalid image_url format' do
      domain.image_url = 'not-a-valid-url'
      expect(domain).not_to be_valid
      expect(domain.errors[:image_url]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:systems) }
  end

  describe 'defaults' do
    it 'defaults status to active' do
      expect(described_class.new.status).to eq('active')
    end
  end
end
