# frozen_string_literal: true

FactoryBot.define do
  factory "junction/user", aliases: [ :user ], class: "Junction::User" do
    sequence(:title) { |n| "Test User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { Faker::Internet.password(max_length: 72, special_characters: true) }
    password_confirmation { password }
    image_url { TEST_IMAGE_URL }
  end
end
