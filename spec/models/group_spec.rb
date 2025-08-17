# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    subject(:group) { build(:group) }

    it 'is valid with valid attributes' do
      expect(group).to be_valid
    end

    it 'is invalid without a name' do
      group.name = nil
      expect(group).not_to be_valid
      expect(group.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      create(:group, name: 'Duplicate Name')
      group.name = 'Duplicate Name'
      expect(group).not_to be_valid
      expect(group.errors[:name]).to include('has already been taken')
    end

    it 'is invalid without a description' do
      group.description = nil
      expect(group).not_to be_valid
      expect(group.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a group_type' do
      group.group_type = nil
      expect(group).not_to be_valid
      expect(group.errors[:group_type]).to include("can't be blank")
    end

    it 'is valid with a blank email' do
      group.email = ''
      expect(group).to be_valid
    end

    it 'is invalid with an invalid email format' do
      group.email = 'not-an-email'
      expect(group).not_to be_valid
      expect(group.errors[:email]).to include('is invalid')
    end

    it 'is valid with a blank image_url' do
      group.image_url = ''
      expect(group).to be_valid
    end

    it 'is invalid with an invalid image_url format' do
      group.image_url = 'not-a-valid-url'
      expect(group).not_to be_valid
      expect(group.errors[:image_url]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:parent).class_name('Group').optional }
    it { is_expected.to have_many(:children).class_name('Group').with_foreign_key('parent_id').dependent(:destroy) }
    it { is_expected.to have_many(:group_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:group_memberships).source(:user) }
  end

  describe 'defaults' do
    it 'defaults group_type to "team"' do
      expect(described_class.new.group_type).to eq('team')
    end
  end

  describe '#icon' do
    it 'returns the icon for a known group type' do
      allow(CatalogOptions).to receive(:group_types).and_return({ 'team' => { icon: 'team-icon' } })
      group = build(:group, group_type: 'team')
      expect(group.icon).to eq('team-icon')
    end

    it 'returns the default icon for an unknown group type' do
      allow(CatalogOptions).to receive(:group_types).and_return({})
      group = build(:group, group_type: 'unknown-type')
      expect(group.icon).to eq('users-round')
    end
  end

  describe '#self_and_ancestors' do
    it 'returns only itself when it has no parent' do
      group = create(:group)
      expect(group.self_and_ancestors).to contain_exactly(group)
    end

    it 'returns itself and its parent' do
      parent = create(:group)
      child = create(:group, parent: parent)
      expect(child.self_and_ancestors).to contain_exactly(child, parent)
    end

    it 'returns itself and all ancestors in the hierarchy' do
      grandparent = create(:group)
      parent = create(:group, parent: grandparent)
      child = create(:group, parent: parent)
      expect(child.self_and_ancestors).to contain_exactly(child, parent, grandparent)
    end
  end
end
