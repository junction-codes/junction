require 'rails_helper'

RSpec.describe "domains/index", type: :view do
  before do
    parent_domain = Junction::Domain.create!(
      title: "Name",
      type: "product-area",
      description: "MyText",
      image_url: "https://example.com/image.png",
      owner: create(:group)
    )

    assign(:domains, [
      parent_domain,
      Junction::Domain.create!(
        title: "Second Name",
        type: "product-group",
        description: "MyText",
        image_url: nil,
        owner: create(:group),
        parent: parent_domain
      )
    ])
  end

  it "renders a list of domains" do
    skip "implement tests for phlex views"
  end
end
