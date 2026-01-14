require 'rails_helper'

RSpec.describe "deployments/edit", type: :view do
  fixtures :components

  let(:deployment) {
    Junction::Deployment.create!(
      environment: "staging",
      platform: "aws",
      location_identifier: "MyString",
      component: components(:one)
    )
  }

  before do
    assign(:deployment, deployment)
  end

  it "renders the edit deployment form" do
    skip "implement tests for phlex views"
  end
end
