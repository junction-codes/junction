require 'rails_helper'

RSpec.describe "domains/edit", type: :view do
  let(:domain) {
    Domain.create!(
      name: "MyString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil
    )
  }

  before(:each) do
    # assign(:domain, domain)
  end

  it "renders the edit domain form" do
    skip "implement tests for phlex views"

    render

    assert_select "form[action=?][method=?]", domain_path(domain), "post" do

      assert_select "input[name=?]", "domain[name]"

      assert_select "textarea[name=?]", "domain[description]"

      assert_select "input[name=?]", "domain[status]"

      assert_select "input[name=?]", "domain[image_url]"

      assert_select "input[name=?]", "domain[owner_id]"
    end
  end
end
