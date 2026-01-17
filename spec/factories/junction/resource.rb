# frozen_string_literal: true

FactoryBot.define do
  factory "junction/resource", aliases: [ :resource ], class: "Junction::Resource" do
    sequence(:name) { |n| "Resource Name #{n}" }
    description { Faker::Lorem.paragraph }
    resource_type { Junction::CatalogOptions.resources.keys.sample }
    image_url { 'https://example.com/image.png' }

    association :owner, factory: :group
    association :system
  end
end
