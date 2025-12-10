require 'rails_helper'

RSpec.describe Resource, type: :model do
  subject(:resource) { build(:resource) }

  it_behaves_like "a model with dependencies"
  it_behaves_like "a model that can be depended on"
  it_behaves_like "a model that can be owned"
end
