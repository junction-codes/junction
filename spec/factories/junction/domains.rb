# frozen_string_literal: true

FactoryBot.define do
  factory "junction/domain", aliases: [ :domain ], class: "Junction::Domain" do
    sequence(:title) { |n| "Domain #{n}" }
    description { Faker::Lorem.paragraph }
    type { Junction::CatalogOptions.domains.keys.sample }
    image_url { TEST_IMAGE_URL }
    parent { nil }
    association :owner, factory: :group

    trait :with_parent do
      association :parent, factory: :domain
    end
  end
end
