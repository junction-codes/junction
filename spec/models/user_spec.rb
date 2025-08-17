# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:user) { build(:user) }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without a display_name' do
      user.display_name = nil
      expect(user).not_to be_valid
      expect(user.errors[:display_name]).to include("can't be blank")
    end

    it 'is invalid without an email_address' do
      user.email_address = nil
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email_address' do
      create(:user, email_address: 'test@example.com')
      user.email_address = 'test@example.com'
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include('has already been taken')
    end

    it 'is invalid with an invalid email_address format' do
      user.email_address = 'not-an-email'
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include('is invalid')
    end

    it 'is invalid without a password' do
      user.password = nil
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is invalid if password is too short' do
      user.password = 'short'
      user.password_confirmation = 'short'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'is invalid if password confirmation does not match' do
      user.password_confirmation = 'wrong_password'
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it 'is valid when updating attributes without changing the password' do
      user.save!
      user.display_name = 'New Name'
      expect(user).to be_valid
    end

    it 'is valid with a blank image_url' do
      user.image_url = ''
      expect(user).to be_valid
    end

    it 'is invalid with an invalid image_url format' do
      user.image_url = 'not-a-valid-url'
      expect(user).not_to be_valid
      expect(user.errors[:image_url]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:group_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:group_memberships) }
  end

  describe 'normalizations' do
    it 'downcases and strips the email address before validation' do
      user = build(:user, email_address: '  TEST@EXAMPLE.COM  ')
      user.valid?
      expect(user.email_address).to eq('test@example.com')
    end
  end

  describe '#deep_group_ids' do
    it 'returns ids of all groups the user is a member of, including ancestors' do
      grandparent = create(:group)
      parent = create(:group, parent: grandparent)
      child = create(:group, parent: parent)
      user = create(:user, groups: [child])

      expect(user.deep_group_ids.map(&:id)).to contain_exactly(child.id, parent.id, grandparent.id)
    end
  end

  describe '#components' do
    it 'returns components owned by the user\'s groups and their ancestors' do
      grandparent = create(:group)
      parent = create(:group, parent: grandparent)
      child = create(:group, parent: parent)
      user = create(:user, groups: [child])

      component1 = create(:component, owner: child)
      component2 = create(:component, owner: parent)
      component3 = create(:component, owner: grandparent)
      _unrelated_component = create(:component)

      expect(user.components).to contain_exactly(component1, component2, component3)
    end
  end

  describe '#systems' do
    it 'returns systems owned by the user\'s groups and their ancestors' do
      grandparent = create(:group)
      parent = create(:group, parent: grandparent)
      child = create(:group, parent: parent)
      user = create(:user, groups: [child])

      system1 = create(:system, owner: child)
      system2 = create(:system, owner: parent)
      system3 = create(:system, owner: grandparent)
      _unrelated_system = create(:system)

      expect(user.systems).to contain_exactly(system1, system2, system3)
    end
  end
end
