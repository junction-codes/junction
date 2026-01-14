require 'rails_helper'

RSpec.describe "systems/index", type: :view do
  fixtures :domains

  before do
    assign(:systems, [
      Junction::System.create!(
        name: "Name",
        description: "MyText",
        status: "active",
        image_url: "https://example.com/image.png",
        domain: domains(:one),
        owner: nil
      ),
      Junction::System.create!(
        name: "Second Name",
        description: "MyText",
        status: "closed",
        image_url: nil,
        domain: domains(:two),
        owner: nil
      )
    ])
  end

  it "renders a list of systems" do
    skip "implement tests for phlex views"
  end
end
