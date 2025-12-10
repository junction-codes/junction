# frozen_string_literal: true

FactoryBot.define do
  factory :dependency do
    association :source, factory: :component
    association :target, factory: :api
  end
end
