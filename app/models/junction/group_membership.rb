# frozen_string_literal: true

module Junction
  class GroupMembership < ApplicationRecord
    validates :user_id, uniqueness: { scope: :group_id }

    belongs_to :group, class_name: "Junction::Group"
    belongs_to :user, class_name: "Junction::User"
  end
end
