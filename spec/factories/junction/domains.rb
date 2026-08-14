# frozen_string_literal: true

FactoryBot.define do
  factory "junction/domain", aliases: [ :domain ], class: "Junction::Domain" do
    sequence(:title) { |n| "Domain #{n}" }
    description { Faker::Lorem.paragraph }
    domain_type { Junction::CatalogOptions.domains.keys.sample }
    image_url { TEST_IMAGE_URL }
    parent { nil }
    status { [ "active", "closed" ].sample }
    association :owner, factory: :group

    trait :without_owner do
      owner { nil }
    end

    trait :with_parent do
      association :parent, factory: :domain
    end
  end
end
