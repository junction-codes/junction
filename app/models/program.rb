# frozen_string_literal: true

class Program < ApplicationRecord
  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :logo_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  def projects
    [
      ActiveSupport::OrderedOptions.new.tap do |o|
        o.name = 'Project A'
        o.status ='active'
        o.id = 1
        o.description = 'This is the first project.'
      end
    ]
  end

  def services
    [
      ActiveSupport::OrderedOptions.new.tap do |o|
        o.name = 'Service 1'
        o.status = 'active'
        o.id = 1
        o.description = 'This is the first service.'
      end
    ]
  end
end
