# frozen_string_literal: true

module Junction
  # Concern for models that are owned by a group.
  #
  # Every catalog entity must have an owner, so the association is required.
  module Ownable
    extend ActiveSupport::Concern

    included do
      belongs_to :owner, class_name: "Junction::Group", optional: false
    end
  end
end
