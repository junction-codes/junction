require 'rails_helper'

RSpec.describe "systems/edit", type: :view do
  fixtures :domains

  let(:system) {
    System.create!(
      name: "MyEditString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      domain: domains(:one),
      owner: nil
    )
  }

  before(:each) do
    assign(:system, system)
  end

  it "renders the edit system form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", system_path(system), "post" do
      assert_select "input[name=?]", "system[name]"

      assert_select "textarea[name=?]", "system[description]"

      assert_select "input[name=?]", "system[status]"

      assert_select "input[name=?]", "system[image_url]"

      assert_select "input[name=?]", "system[domain_id]"

      assert_select "input[name=?]", "system[owner_id]"
    end
  end
end
