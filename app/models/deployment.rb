# frozen_string_literal: true

class Deployment < ApplicationRecord
  validates :environment, presence: true, inclusion: { in: %w[demo development production qa sandbox staging testing] }
  validates :platform, presence: true

  belongs_to :component

  def self.ransackable_associations(auth_object = nil)
    %w[component]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at component_id environment location_identifier platform updated_at]
  end
end
