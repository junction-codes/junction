# frozen_string_literal: true

FactoryBot.define do
  factory "junction/group", aliases: [ :group ], class: "Junction::Group" do
    sequence(:name) { |n| "Group #{n}" }
    description { Faker::Lorem.paragraph }
    sequence(:email) { |n| "group-#{n}@example.com" }
    group_type { Junction::CatalogOptions.group_types.keys.sample }
    image_url { Faker::Internet.url }
    parent { nil }

    trait :with_parent do
      association :parent, factory: :group
    end
  end
end
