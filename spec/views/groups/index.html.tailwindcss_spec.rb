require 'rails_helper'

RSpec.describe "groups/index", type: :view do
  before do
    assign(:groups, [
      Group.create!(
        name: "Name",
        description: "MyText",
        group_type: "team",
        email: "team@example.com",
        image_url: "https://example.com/image.png",
        parent: nil
      ),
      Group.create!(
        name: "Second Name",
        description: "MyText",
        group_type: "business_unit",
        email: "bu@example.com",
        image_url: nil,
        parent: nil
      )
    ])
  end

  it "renders a list of groups" do
    skip "implement tests for phlex views"
  end
end
