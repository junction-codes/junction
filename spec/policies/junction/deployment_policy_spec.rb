# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::DeploymentPolicy, type: :policy do
  let(:user) { build_stubbed(:user) }
  let(:record) { build_stubbed(:deployment) }
  let(:policy) { described_class.new(record, user: user) }

  it_behaves_like "an application policy with context", "deployments"
end
