# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::HasAnnotations do
  it_behaves_like "a controller with annotation params", Junction::GroupsController
  it_behaves_like "a controller with annotation params", Junction::DomainsController
  it_behaves_like "a controller with annotation params", Junction::SystemsController
end
