# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::IconHelper do
  before do
    stub_const("IconProbe", Class.new(Junction::Components::Base) do
      def initialize(name, fallback)
        @name = name
        @fallback = fallback

        super()
      end

      def view_template
        icon(@name, fallback: @fallback, class: "w-4 h-4")
      end
    end)
  end

  def render(name, fallback = "circle")
    Junction::ApplicationController.renderer
                                   .render(IconProbe.new(name, fallback))
  end

  it "renders the icon when the name resolves" do
    expect(render("link")).to include("<svg")
  end

  it "falls back rather than raising on an unknown name" do
    expect { render("grafana") }.not_to raise_error
  end

  it "renders the fallback for an unknown name" do
    expect(render("grafana")).to eq(render("circle"))
  end

  it "renders the fallback when the name is blank" do
    expect(render("")).to eq(render("circle"))
  end

  it "renders the fallback when the name is nil" do
    expect(render(nil)).to eq(render("circle"))
  end

  it "still raises when the fallback itself is unknown" do
    expect { render("grafana", "also-missing") }
      .to raise_error(Icons::IconNotFound)
  end

  it "raises for an unknown name when no fallback is given" do
    expect { render("grafana", nil) }.to raise_error(Icons::IconNotFound)
  end
end
