require 'rails_helper'

RSpec.describe "systems/new", type: :view do
  fixtures(*ENTITY_FIXTURE_SETS)

  before do
    assign(:system, Junction::System.new(
      name: "MyString",
      type: "service",
      description: "MyText",
      image_url: "https://example.com/image.png",
      domain: junction_domains(:domain_one),
      owner: nil
    ))
  end

  it "renders new system form" do
    skip "implement tests for phlex views"
  end
end
