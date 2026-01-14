require 'rails_helper'

RSpec.describe "deployments/new", type: :view do
  before do
    assign(:deployment, Junction::Deployment.new(
      environment: "staging",
      platform: "aws",
      location_identifier: "MyString",
      component: nil
    ))
  end

  it "renders new deployment form" do
    skip "implement tests for phlex views"
  end
end
