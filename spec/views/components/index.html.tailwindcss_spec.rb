require 'rails_helper'

RSpec.describe "components/index", type: :view do
  before do
    assign(:components, [
      Component.create!(
        name: "Name",
        description: "MyText",
        lifecycle: "production",
        component_type: "api",
        image_url: "https://example.com/image.png",
        owner: nil
      ),
      Component.create!(
        name: "Second Name",
        description: "MyText",
        lifecycle: "experimental",
        component_type: "worker",
        image_url: nil,
        owner: nil
      )
    ])
  end

  it "renders a list of components" do
    skip "implement tests for phlex views"
  end
end
