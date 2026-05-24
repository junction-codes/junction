require 'rails_helper'

RSpec.describe "domains/show", type: :view do
  before do
    assign(:domain, Junction::Domain.create!(
      title: "Name",
      domain_type: "product-group",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
