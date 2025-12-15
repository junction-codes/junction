require 'rails_helper'

RSpec.describe "groups/new", type: :view do
  before do
    assign(:group, Group.new(
      name: "MyString",
      description: "MyText",
      group_type: "team",
      email: "team@example.com",
      image_url: "https://example.com/image.png",
      parent: nil
    ))
  end

  it "renders new group form" do
    skip "implement tests for phlex views"
  end
end
