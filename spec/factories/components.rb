# frozen_string_literal: true

FactoryBot.define do
  factory :component do
    sequence(:name) { |n| "Component Name #{n}" }
    description { Faker::Lorem.paragraph }
    component_type { CatalogOptions.kinds.keys.sample }
    lifecycle { CatalogOptions.lifecycles.keys.sample }
    image_url { 'https://example.com/image.png' }
  end
end
