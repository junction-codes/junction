require 'rails_helper'

RSpec.describe "components/new", type: :view do
  before do
    assign(:component, Junction::Component.new(
      name: "MyString",
      description: "MyText",
      lifecycle: "production",
      component_type: "api",
      image_url: "https://example.com/image.png",
      owner: nil
    ))
  end

  it "renders new component form" do
    skip "implement tests for phlex views"
  end
end
