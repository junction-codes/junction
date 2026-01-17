# frozen_string_literal: true

module Junction
  # Concern for models that can be owned.
  module Ownable
    extend ActiveSupport::Concern

    included do
      belongs_to :owner, class_name: "Junction::Group", optional: true
    end
  end
end
