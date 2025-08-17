require 'rails_helper'

RSpec.describe "deployments/show", type: :view do
  fixtures :components

  before(:each) do
    assign(:deployment, Deployment.create!(
      environment: "staging",
      platform: "aws",
      location_identifier: "Location Identifier",
      component: components(:one)
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"

    render
    expect(rendered).to match(/Environment/)
    expect(rendered).to match(/Platform/)
    expect(rendered).to match(/Location Identifier/)
    expect(rendered).to match(//)
  end
end
