# frozen_string_literal: true

FactoryBot.define do
  factory "junction/credential", aliases: [ :credential ], class: "Junction::Credential" do
    password { Faker::Internet.password(max_length: 72, special_characters: true) }
    password_confirmation { password }

    association :entity, factory: :user
  end
end
