# frozen_string_literal: true

FactoryBot.define do
  factory "junction/group", aliases: [ :group ], class: "Junction::Group" do
    sequence(:title) { |n| "Group #{n}" }
    description { Faker::Lorem.paragraph }
    sequence(:email) { |n| "group-#{n}@example.com" }
    group_type { Junction::CatalogOptions.groups.keys.sample }
    image_url { TEST_IMAGE_URL }
    parent { nil }

    trait :with_parent do
      association :parent, factory: :group
    end
  end
end
