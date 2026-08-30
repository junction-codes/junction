require 'rails_helper'

RSpec.describe "systems/edit", type: :view do
  fixtures "junction/groups", "junction/domains"

  let(:system) {
    Junction::System.create!(
      title: "MyEditString",
      system_type: "service",
      description: "MyText",
      image_url: "https://example.com/image.png",
      domain: junction_domains(:one),
      owner: create(:group)
    )
  }

  before do
    assign(:system, system)
  end

  it "renders the edit system form" do
    skip "implement tests for phlex views"
  end
end
