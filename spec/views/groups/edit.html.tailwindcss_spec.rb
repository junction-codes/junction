require 'rails_helper'

RSpec.describe "groups/edit", type: :view do
  let(:group) {
    Group.create!(
      name: "MyEditString",
      description: "MyText",
      group_type: "team",
      email: "team@example.com",
      image_url: "https://example.com/image.png",
      parent: nil
    )
  }

  before do
    assign(:group, group)
  end

  it "renders the edit group form" do
    skip "implement tests for phlex views"
  end
end
