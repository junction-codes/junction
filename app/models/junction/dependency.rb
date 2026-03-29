# frozen_string_literal: true

module Junction
  class Dependency < ApplicationRecord
    validates :target_id, presence: true
    validates :target_type, presence: true,
              inclusion: { in: %w[Junction::Api Junction::Component Junction::Resource] }

    belongs_to :source, polymorphic: true
    belongs_to :target, polymorphic: true
  end
end
