# frozen_string_literal: true

FactoryBot.define do
  factory "junction/system", aliases: [ :system ], class: "Junction::System" do
    sequence(:title) { |n| "System #{n}" }
    description { Faker::Lorem.paragraph }
    system_type { Junction::CatalogOptions.systems.keys.sample }
    image_url { TEST_IMAGE_URL }
    association :domain
    association :owner, factory: :group
  end
end
