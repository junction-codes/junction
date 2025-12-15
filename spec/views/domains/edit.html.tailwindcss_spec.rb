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

  it "renders the edit domain form" do
    skip "implement tests for phlex views"
  end
end
