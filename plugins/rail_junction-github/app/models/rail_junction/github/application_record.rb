module RailJunction
  module Github
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
