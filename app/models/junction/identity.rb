# frozen_string_literal: true

module Junction
  class Identity < ApplicationRecord
    belongs_to :user, class_name: "Junction::User"

    validates :uid, presence: true, uniqueness: { scope: :provider }
    validates :provider, presence: true
  end
end
