require 'rails_helper'

RSpec.describe "groups/new", type: :view do
  before(:each) do
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

    render

    assert_select "form[action=?][method=?]", groups_path, "post" do
      assert_select "input[name=?]", "group[name]"

      assert_select "input[name=?]", "group[group_type]"

      assert_select "input[name=?]", "group[email]"

      assert_select "input[name=?]", "group[image_url]"

      assert_select "input[name=?]", "group[parent_id]"
    end
  end
end
