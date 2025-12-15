require 'rails_helper'

RSpec.describe "components/edit", type: :view do
  let(:component) {
    Component.create!(
      name: "MyEditString",
      description: "MyText",
      lifecycle: "production",
      component_type: "api",
      image_url: "https://example.com/image.png",
      owner: nil
    )
  }

  before do
    assign(:component, component)
  end

  it "renders the edit component form" do
    skip "implement tests for phlex views"
  end
end
