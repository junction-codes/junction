require 'rails_helper'

RSpec.describe "deployments/index", type: :view do
  fixtures :components

  before(:each) do
    assign(:deployments, [
      Deployment.create!(
        environment: "staging",
        platform: "aws",
        location_identifier: "Location Identifier",
        component: components(:one)
      ),
      Deployment.create!(
        environment: "production",
        platform: "aptible",
        location_identifier: "Location Identifier",
        component: components(:two)
      )
    ])
  end

  it "renders a list of deployments" do
    skip "implement tests for phlex views"

    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Environment".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Platform".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Location Identifier".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
