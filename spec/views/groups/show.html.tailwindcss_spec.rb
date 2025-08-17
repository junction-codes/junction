require 'rails_helper'

RSpec.describe "groups/show", type: :view do
  before(:each) do
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

    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Group Type/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Image Url/)
    expect(rendered).to match(//)
  end
end
