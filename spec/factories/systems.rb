# frozen_string_literal: true

FactoryBot.define do
  factory :system do
    sequence(:name) { |n| "System #{n}" }
    description { Faker::Lorem.paragraph }
    status { %w[active closed].sample }
    image_url { Faker::Internet.url }
    association :domain
    association :owner, factory: :group

    trait :without_owner do
      owner { nil }
    end
  end
end
