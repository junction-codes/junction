# frozen_string_literal: true

module Junction
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = "junction_"

    # Get the icon associated with the record.
    #
    # @return [String] The icon name.
    def icon
      "circle"
    end
  end
end
