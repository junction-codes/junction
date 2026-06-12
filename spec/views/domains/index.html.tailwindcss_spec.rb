require 'rails_helper'

RSpec.describe "domains/index", type: :view do
  before do
    parent_domain = Junction::Domain.create!(
      title: "Name",
      domain_type: "product-area",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil
    )

    assign(:domains, [
      parent_domain,
      Junction::Domain.create!(
        title: "Second Name",
        domain_type: "product-group",
        description: "MyText",
        status: "closed",
        image_url: nil,
        owner: nil,
        parent: parent_domain
      )
    ])
  end

  it "renders a list of domains" do
    skip "implement tests for phlex views"
  end
end
