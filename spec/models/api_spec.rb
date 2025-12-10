require 'rails_helper'

RSpec.describe Api, type: :model do
  subject(:api) { build(:api) }

  it_behaves_like "a model with dependencies"
  it_behaves_like "a model that can be depended on"
  it_behaves_like "a model that can be owned"
end
