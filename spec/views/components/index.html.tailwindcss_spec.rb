require 'rails_helper'

RSpec.describe "components/index", type: :view do
  before do
    assign(:components, [
      Junction::Component.create!(
        title: "Name",
        description: "MyText",
        lifecycle: "production",
        type: "api",
        image_url: "https://example.com/image.png",
        owner: create(:group)
      ),
      Junction::Component.create!(
        title: "Second Name",
        description: "MyText",
        lifecycle: "experimental",
        type: "worker",
        image_url: nil,
        owner: create(:group)
      )
    ])
  end

  it "renders a list of components" do
    skip "implement tests for phlex views"
  end
end
