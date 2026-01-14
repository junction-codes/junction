# frozen_string_literal: true

FactoryBot.define do
  factory :identity, class: "Junction::Identity" do
    provider { %w[amazon github google okta].sample }

    association :user
  end
end
