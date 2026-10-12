# frozen_string_literal: true

require "rails_helper"

# The logo is drawn once and used twice: inline in the UI, where it takes the
# color of whatever tile it sits in, and baked into the favicon, which needs
# its own background because nothing contains it. The two files can't be one, so
# this test ensures that the favicon is drawn from the same shapes as the logo.
RSpec.describe Junction::Components::Logo do
  let(:logo) { Junction::Engine.root.join(Junction::Components::Logo::PATH).read }
  let(:favicon) { Junction::Engine.root.join("public/icon.svg").read }

  def shapes(svg)
    Nokogiri::XML(svg).css("circle, path").map do |shape|
      shape.attributes.transform_values(&:value)
    end
  end

  it "draws the favicon from the same shapes" do
    expect(shapes(favicon)).to include(*shapes(logo))
  end

  it "gives the favicon its own background" do
    expect(Nokogiri::XML(favicon).at_css("rect")).to be_present
  end

  it "gives the favicon a stroke colour of its own" do
    expect(favicon).to include('stroke="#ffffff"')
  end

  it "leaves the inline logo taking its colour from the page" do
    expect(logo).to include('stroke="currentColor"')
  end
end
