# frozen_string_literal: true

module Junction
  class Session < Junction::ApplicationRecord
    belongs_to :user, class_name: "Junction::User"
  end
end
