# frozen_string_literal: true

module HasDependents
  extend ActiveSupport::Concern

  private

  def dependents
    (
      @entity.api_dependents +
      @entity.component_dependents +
      @entity.resource_dependents
    ).sort_by(&:name)
  end
end
