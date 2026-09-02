# frozen_string_literal: true

FactoryBot.define do
  factory "junction/relation", aliases: [ :relation ], class: "Junction::Relation" do
    relation_type { Junction::Relation::DEPENDS_ON }

    association :source, factory: :component
    association :target, factory: :api
  end
end
