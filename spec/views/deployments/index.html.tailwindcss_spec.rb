require 'rails_helper'

RSpec.describe "deployments/index", type: :view do
  fixtures :components

  before do
    assign(:deployments, [
      Junction::Deployment.create!(
        environment: "staging",
        platform: "aws",
        location_identifier: "Location Identifier",
        component: components(:one)
      ),
      Junction::Deployment.create!(
        environment: "production",
        platform: "aptible",
        location_identifier: "Location Identifier",
        component: components(:two)
      )
    ])
  end

  it "renders a list of deployments" do
    skip "implement tests for phlex views"
  end
end
