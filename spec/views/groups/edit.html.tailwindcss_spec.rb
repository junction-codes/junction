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

  before(:each) do
    assign(:group, group)
  end

  it "renders the edit group form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", group_path(group), "post" do
      assert_select "input[name=?]", "group[name]"

      assert_select "input[name=?]", "group[group_type]"

      assert_select "input[name=?]", "group[email]"

      assert_select "input[name=?]", "group[image_url]"

      assert_select "input[name=?]", "group[parent_id]"
    end
  end
end
