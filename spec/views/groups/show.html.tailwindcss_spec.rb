require 'rails_helper'

RSpec.describe "groups/show", type: :view do
  before do
    assign(:group, Group.create!(
      name: "Name",
      description: "MyText",
      group_type: "team",
      email: "team@example.com",
      image_url: "https://example.com/image.png",
      parent: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
