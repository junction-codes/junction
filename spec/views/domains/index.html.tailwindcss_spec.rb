require 'rails_helper'

RSpec.describe "domains/index", type: :view do
  before do
    assign(:domains, [
      Junction::Domain.create!(
        name: "Name",
        description: "MyText",
        status: "active",
        image_url: "https://example.com/image.png",
        owner: nil
      ),
      Junction::Domain.create!(
        name: "Second Name",
        description: "MyText",
        status: "closed",
        image_url: nil,
        owner: nil
      )
    ])
  end

  it "renders a list of domains" do
    skip "implement tests for phlex views"
  end
end
