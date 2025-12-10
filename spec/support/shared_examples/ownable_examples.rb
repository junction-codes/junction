# frozen_string_literal: true

RSpec.shared_examples 'a model that can be owned' do
  describe 'ownable associations' do
    it { is_expected.to belong_to(:owner).class_name("Group").optional }
  end

  describe 'ownable behavior' do
    let(:group) { create(:group) }

    it 'can be assigned an owner' do
      subject.owner = group

      subject.save!
      expect(subject.owner).to eq(group)
    end
  end
end
