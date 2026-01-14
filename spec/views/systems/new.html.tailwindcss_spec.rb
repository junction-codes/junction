require 'rails_helper'

RSpec.describe "systems/new", type: :view do
  fixtures :domains

  before do
    assign(:system, Junction::System.new(
      name: "MyString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      domain: domains(:one),
      owner: nil
    ))
  end

  it "renders new system form" do
    skip "implement tests for phlex views"
  end
end
