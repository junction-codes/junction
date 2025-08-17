require 'rails_helper'

RSpec.describe "groups/index", type: :view do
  before(:each) do
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

    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Group Type".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Email".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Image Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
