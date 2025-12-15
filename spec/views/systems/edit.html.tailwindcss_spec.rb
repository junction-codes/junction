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

  before do
    assign(:system, system)
  end

  it "renders the edit system form" do
    skip "implement tests for phlex views"
  end
end
