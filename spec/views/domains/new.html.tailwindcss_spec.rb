require 'rails_helper'

RSpec.describe "domains/new", type: :view do
  before(:each) do
    assign(:domain, Domain.new(
      name: "MyString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil
    ))
  end

  it "renders new domain form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", domains_path, "post" do

      assert_select "input[name=?]", "domain[name]"

      assert_select "textarea[name=?]", "domain[description]"

      assert_select "input[name=?]", "domain[status]"

      assert_select "input[name=?]", "domain[image_url]"

      assert_select "input[name=?]", "domain[owner_id]"
    end
  end
end
