# frozen_string_literal: true

module Junction
  class Dependency < ApplicationRecord
    belongs_to :source, polymorphic: true
    belongs_to :target, polymorphic: true

    validates :target_type, presence: true
    validates :target_id, presence: true
  end
end
