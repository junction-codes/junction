require 'rails_helper'

RSpec.describe "domains/index", type: :view do
  before do
    assign(:domains, [
      Junction::Domain.create!(
        title: "Name",
        domain_type: "product-area",
        description: "MyText",
        status: "active",
        image_url: "https://example.com/image.png",
        owner: nil
      ),
      Junction::Domain.create!(
        title: "Second Name",
        domain_type: "product-group",
        description: "MyText",
        status: "closed",
        image_url: nil,
        owner: nil,
        parent: Junction::Domain.first
      )
    ])
  end

  it "renders a list of domains" do
    skip "implement tests for phlex views"
  end
end
