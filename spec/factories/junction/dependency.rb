# frozen_string_literal: true

FactoryBot.define do
  factory "junction/dependency", aliases: [ :dependency ], class: "Junction::Dependency" do
    association :source, factory: :component
    association :target, factory: :api
  end
end
