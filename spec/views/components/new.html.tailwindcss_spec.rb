require 'rails_helper'

RSpec.describe "components/new", type: :view do
  before(:each) do
    assign(:component, Component.new(
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

    render

    assert_select "form[action=?][method=?]", components_path, "post" do
      assert_select "input[name=?]", "component[name]"

      assert_select "textarea[name=?]", "component[description]"

      assert_select "input[name=?]", "component[lifecycle]"

      assert_select "input[name=?]", "component[component_type]"

      assert_select "input[name=?]", "component[repository_url]"

      assert_select "input[name=?]", "component[image_url]"

      assert_select "input[name=?]", "component[domain_id]"

      assert_select "input[name=?]", "component[owner_id]"
    end
  end
end
