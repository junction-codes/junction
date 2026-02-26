# frozen_string_literal: true

FactoryBot.define do
  factory "junction/role", aliases: [ :role ], class: "Junction::Role" do
    sequence(:name) { |n| "Role Name #{n}" }
    description { Faker::Lorem.sentence }
    system { false }

    trait :system do
      system { true }
    end

    trait :with_permissions do
      after(:create) do |role|
        create_list(:role_permission, 2, role: role)
      end
    end
  end
end
