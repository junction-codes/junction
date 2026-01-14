# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership, class: "Junction::GroupMembership", class: "Junction::Group_membership" do
    association :user
    association :group
  end
end
