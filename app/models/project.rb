class Project < ApplicationRecord
  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :program

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
