# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Group, type: :model do
  describe "validations" do
    subject(:group) { build(:group) }

    it "is valid with valid attributes" do
      expect(group).to be_valid
    end

    it_behaves_like "validates presence of", :description
    it_behaves_like "validates email format of", :email
    it_behaves_like "validates presence of", :group_type
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name
    it_behaves_like "validates image_url format"
  end

  describe 'associations' do
    it { is_expected.to have_many(:children).class_name('Group').with_foreign_key('parent_id').dependent(:destroy) }
    it { is_expected.to have_many(:group_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:group_memberships).source(:user) }
    it { is_expected.to belong_to(:parent).class_name('Group').optional }
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
