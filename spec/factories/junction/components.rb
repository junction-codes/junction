# frozen_string_literal: true

FactoryBot.define do
  factory "junction/component", aliases: [ :component ], class: "Junction::Component" do
    sequence(:title) { |n| "Component Name #{n}" }
    description { Faker::Lorem.paragraph }
    type { Junction::CatalogOptions.components.keys.sample }
    lifecycle { Junction::CatalogOptions.lifecycles.keys.sample }
    image_url { TEST_IMAGE_URL }

    association :owner, factory: :group
  end
end
