require 'rails_helper'

RSpec.describe "deployments/show", type: :view do
  fixtures :components

  before do
    assign(:deployment, Junction::Deployment.create!(
      environment: "staging",
      platform: "aws",
      location_identifier: "Location Identifier",
      component: components(:one)
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
