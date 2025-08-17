require 'rails_helper'

RSpec.describe "systems/new", type: :view do
  fixtures :domains

  before(:each) do
    assign(:system, System.new(
      name: "MyString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      domain: domains(:one),
      owner: nil
    ))
  end

  it "renders new system form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", systems_path, "post" do
      assert_select "input[name=?]", "system[name]"

      assert_select "textarea[name=?]", "system[description]"

      assert_select "input[name=?]", "system[status]"

      assert_select "input[name=?]", "system[image_url]"

      assert_select "input[name=?]", "system[domain_id]"

      assert_select "input[name=?]", "system[owner_id]"
    end
  end
end
