# frozen_string_literal: true

FactoryBot.define do
  factory "junction/template", aliases: [ :template ], class: "Junction::Template" do
    sequence(:title) { |n| "Template #{n}" }
    description { Faker::Lorem.paragraph }
    type { Junction::CatalogOptions.section(:templates).keys.sample || "service" }
    image_url { TEST_IMAGE_URL }

    association :owner, factory: :group
  end
end
