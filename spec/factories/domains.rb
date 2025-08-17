# frozen_string_literal: true

FactoryBot.define do
  factory :domain do
    sequence(:name) { |n| "Domain #{n}" }
    description { Faker::Lorem.paragraph }
    status { ["active", "closed"].sample }
    image_url { "https://example.com/image.png" }
    association :owner, factory: :group

    trait :without_owner do
      owner { nil }
    end
  end
end
