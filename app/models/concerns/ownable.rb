# frozen_string_literal: true

# Concern for models that can be owned.
module Ownable
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: "Group", optional: true
  end
end
