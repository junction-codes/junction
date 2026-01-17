# frozen_string_literal: true

FactoryBot.define do
  factory "junction/deployment", aliases: [ :deployment ], class: "Junction::Deployment" do
    association :component

    environment { Junction::CatalogOptions.environments.keys.sample }
    platform { Junction::CatalogOptions.platforms.keys.sample }
    location_identifier { Faker::Internet.slug }
  end
end
