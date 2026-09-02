require 'rails_helper'

RSpec.describe "domains/edit", type: :view do
  let(:parent) {
    Junction::Domain.create!(
      title: "Parent Domain",
      name: "parent-domain",
      type: "product-area",
      description: "Parent text"
    )
  }

  let(:domain) {
    Junction::Domain.create!(
      name: "MyString",
      type: "product-area",
      description: "MyText",
      image_url: "https://example.com/image.png",
      owner: create(:group),
      parent: parent
    )
  }

  it "renders the edit domain form" do
    skip "implement tests for phlex views"
  end
end
