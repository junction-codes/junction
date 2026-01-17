# frozen_string_literal: true

FactoryBot.define do
  factory "junction/group_membership", aliases: [ :group_membership ], class: "Junction::GroupMembership" do
    association :user
    association :group
  end
end
