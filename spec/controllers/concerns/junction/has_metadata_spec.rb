# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::HasMetadata do
  it_behaves_like "a controller with metadata params", Junction::ComponentsController
  it_behaves_like "a controller with metadata params", Junction::ApisController
  it_behaves_like "a controller with metadata params", Junction::ResourcesController
  it_behaves_like "a controller with metadata params", Junction::SystemsController
  it_behaves_like "a controller with metadata params", Junction::DomainsController
  it_behaves_like "a controller with metadata params", Junction::GroupsController
  it_behaves_like "a controller with metadata params", Junction::UsersController
end
