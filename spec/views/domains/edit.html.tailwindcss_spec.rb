require 'rails_helper'

RSpec.describe "domains/edit", type: :view do
  let(:parent) {
    Junction::Domain.create!(
      title: "Parent Domain",
      name: "parent-domain",
      domain_type: "product-area",
      description: "Parent text",
      status: "active"
    )
  }

  let(:domain) {
    Junction::Domain.create!(
      name: "MyString",
      domain_type: "product-area",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil,
      parent: parent
    )
  }

  it "renders the edit domain form" do
    skip "implement tests for phlex views"
  end
end
