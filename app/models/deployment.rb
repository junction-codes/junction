class Deployment < ApplicationRecord
  validates :environment, presence: true, inclusion: { in: %w[demo development production qa sandbox staging testing] }
  validates :platform, presence: true

  belongs_to :component
end
