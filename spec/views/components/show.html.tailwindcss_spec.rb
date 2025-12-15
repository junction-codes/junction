require 'rails_helper'

RSpec.describe "components/show", type: :view do
  before do
    assign(:component, Component.create!(
      name: "Name",
      description: "MyText",
      lifecycle: "production",
      component_type: "api",
      image_url: "https://example.com/image.png",
      owner: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
