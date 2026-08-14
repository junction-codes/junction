# frozen_string_literal: true

FactoryBot.define do
  factory "junction/resource", aliases: [ :resource ], class: "Junction::Resource" do
    sequence(:title) { |n| "Resource Name #{n}" }
    description { Faker::Lorem.paragraph }
    resource_type { Junction::CatalogOptions.resources.keys.sample }
    image_url { TEST_IMAGE_URL }

    association :owner, factory: :group
    association :system
  end
end
