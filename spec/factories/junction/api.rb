# frozen_string_literal: true

FactoryBot.define do
  factory "junction/api", aliases: [ :api ], class: "Junction::Api" do
    sequence(:name) { |n| "API Name #{n}" }
    description { Faker::Lorem.paragraph }
    api_type { Junction::CatalogOptions.apis.keys.sample }
    lifecycle { Junction::CatalogOptions.lifecycles.keys.sample }
    image_url { 'https://example.com/image.png' }
    definition { Faker::Json.shallow_json }

    association :owner, factory: :group
    association :system
  end
end
