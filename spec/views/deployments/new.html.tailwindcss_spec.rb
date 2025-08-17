require 'rails_helper'

RSpec.describe "deployments/new", type: :view do
  before(:each) do
    assign(:deployment, Deployment.new(
      environment: "staging",
      platform: "aws",
      location_identifier: "MyString",
      component: nil
    ))
  end

  it "renders new deployment form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", deployments_path, "post" do

      assert_select "input[name=?]", "deployment[environment]"

      assert_select "input[name=?]", "deployment[platform]"

      assert_select "input[name=?]", "deployment[location_identifier]"

      assert_select "input[name=?]", "deployment[component_id]"
    end
  end
end
