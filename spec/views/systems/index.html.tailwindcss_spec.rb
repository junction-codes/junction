require 'rails_helper'

RSpec.describe "systems/index", type: :view do
  fixtures :domains

  before(:each) do
    assign(:systems, [
      System.create!(
        name: "Name",
        description: "MyText",
        status: "active",
        image_url: "https://example.com/image.png",
        domain: domains(:one),
        owner: nil
      ),
      System.create!(
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

    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Image Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
