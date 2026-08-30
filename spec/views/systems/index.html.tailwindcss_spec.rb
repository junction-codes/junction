require 'rails_helper'

RSpec.describe "systems/index", type: :view do
  fixtures "junction/groups", "junction/domains"

  before do
    assign(:systems, [
      Junction::System.create!(
        title: "Name",
        system_type: "service",
        description: "MyText",
        image_url: "https://example.com/image.png",
        domain: junction_domains(:one),
        owner: create(:group)
      ),
      Junction::System.create!(
        title: "Second Name",
        system_type: "service",
        description: "MyText",
        image_url: nil,
        domain: junction_domains(:two),
        owner: create(:group)
      )
    ])
  end

  it "renders a list of systems" do
    skip "implement tests for phlex views"
  end
end
