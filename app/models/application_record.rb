# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Get the icon associated with the record.
  #
  # @return [String] The icon name.
  def icon
    "circle"
  end
end
