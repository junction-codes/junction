require 'rails_helper'

RSpec.describe "systems/index", type: :view do
  fixtures(*ENTITY_FIXTURE_SETS)

  before do
    assign(:systems, [
      Junction::System.create!(
        title: "Name",
        type: "service",
        description: "MyText",
        image_url: "https://example.com/image.png",
        domain: junction_domains(:domain_one),
        owner: create(:group)
      ),
      Junction::System.create!(
        title: "Second Name",
        type: "service",
        description: "MyText",
        image_url: nil,
        domain: junction_domains(:domain_two),
        owner: create(:group)
      )
    ])
  end

  it "renders a list of systems" do
    skip "implement tests for phlex views"
  end
end
