# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:display_name) { |n| "Test User #{n}" }
    sequence(:email_address) { |n| "user-#{n}@example.com" }
    password { Faker::Internet.password(max_length: 72, special_characters: true) }
    password_confirmation { password }
    image_url { Faker::Internet.url }
  end
end
