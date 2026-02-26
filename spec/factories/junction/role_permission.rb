# frozen_string_literal: true

FactoryBot.define do
  factory "junction/role_permission", aliases: [ :role_permission ], class: "Junction::RolePermission" do
    association :role, factory: :role
    sequence(:permission) { |n| "permission.#{n}" }
  end
end
