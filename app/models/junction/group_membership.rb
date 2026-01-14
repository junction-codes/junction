# frozen_string_literal: true

module Junction
  class GroupMembership < ApplicationRecord
  belongs_to :user, class_name: "Junction::User"
  belongs_to :group, class_name: "Junction::Group"
end
end
