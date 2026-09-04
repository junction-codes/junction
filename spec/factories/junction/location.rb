# frozen_string_literal: true

FactoryBot.define do
  factory "junction/location", aliases: [ :location ], class: "Junction::Location" do
    sequence(:title) { |n| "Location #{n}" }
    type { Junction::Location::URL }
    sequence(:target) { |n| "https://example.com/catalog-info-#{n}.yaml" }
  end
end
