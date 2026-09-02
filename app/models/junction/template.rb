# frozen_string_literal: true

module Junction
  # A software template: a parameterised recipe for creating new entities.
  #
  # The parameters, steps, and output declarations live in `spec`, matching
  # Backstage's Template kind. Nothing executes them yet.
  class Template < Entity
    include Ownable

    self.catalog_section = :templates
    self.default_icon = "file-code"

    store_accessor :spec, :parameters, :steps, :output

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id title type updated_at]
    end
  end
end
