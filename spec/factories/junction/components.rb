# frozen_string_literal: true

FactoryBot.define do
  factory "junction/component", aliases: [ :component ], class: "Junction::Component" do
    sequence(:name) { |n| "Component Name #{n}" }
    description { Faker::Lorem.paragraph }
    component_type { Junction::CatalogOptions.kinds.keys.sample }
    lifecycle { Junction::CatalogOptions.lifecycles.keys.sample }
    image_url { 'https://example.com/image.png' }
  end
end
