require 'rails_helper'

RSpec.describe "systems/show", type: :view do
  fixtures(*ENTITY_FIXTURE_SETS)

  before do
    assign(:system, Junction::System.create!(
      title: "Name",
      type: "service",
      description: "MyText",
      image_url: "https://example.com/image.png",
      domain: junction_domains(:domain_one),
      owner: create(:group)
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
