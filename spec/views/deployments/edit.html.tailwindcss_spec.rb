require 'rails_helper'

RSpec.describe "deployments/edit", type: :view do
  fixtures :components

  let(:deployment) {
    Deployment.create!(
      environment: "staging",
      platform: "aws",
      location_identifier: "MyString",
      component: components(:one)
    )
  }

  before(:each) do
    assign(:deployment, deployment)
  end

  it "renders the edit deployment form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", deployment_path(deployment), "post" do

      assert_select "input[name=?]", "deployment[environment]"

      assert_select "input[name=?]", "deployment[platform]"

      assert_select "input[name=?]", "deployment[location_identifier]"

      assert_select "input[name=?]", "deployment[component_id]"
    end
  end
end
