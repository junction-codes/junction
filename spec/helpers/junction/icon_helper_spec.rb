# frozen_string_literal: true

require "rails_helper"
require "tmpdir"

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

  context "when a traversal would land on a file that exists" do
    around do |example|
      Dir.mktmpdir do |dir|
        original = RailsIcons.configuration.icons_path
        RailsIcons.configuration.icons_path = File.join(dir, "icons")

        # Mirror the real "circle" into the temporary root, keeping the
        # library and variant directories the resolver expects.
        library = RailsIcons.configuration.default_library
        real = Dir.glob(File.join(original, library, "**", "circle.svg")).sole
        copy = File.join(dir, "icons", real.sub("#{original}/", ""))
        FileUtils.mkdir_p(File.dirname(copy))
        FileUtils.cp(real, copy)

        # Not an icon; rendering it raises from inside the icons gem, which is
        # not the error `fallback` catches.
        File.write(File.join(dir, "secret.svg"), "not an icon at all")

        example.run
      ensure
        RailsIcons.configuration.icons_path = original
      end
    end

    it "refuses the name instead of reading the file" do
      expect(render("../../../secret")).to eq(render("circle"))
    end
  end

  it "falls back rather than reading a file outside the icon directory" do
    expect(render("../../../../etc/passwd")).to eq(render("circle"))
  end

  it "falls back on a name carrying a path separator" do
    expect(render("outline/circle")).to eq(render("circle"))
  end

  it "falls back on a name carrying a dot" do
    expect(render("../circle")).to eq(render("circle"))
  end

  it "raises rather than crashing when a blank name has no fallback" do
    expect { render("", nil) }.to raise_error(Icons::IconNotFound)
  end

  it "raises rather than crashing when a nil name has no fallback" do
    expect { render(nil, nil) }.to raise_error(Icons::IconNotFound)
  end

  it "still raises when the fallback itself is unknown" do
    expect { render("grafana", "also-missing") }
      .to raise_error(Icons::IconNotFound)
  end

  it "raises for an unknown name when no fallback is given" do
    expect { render("grafana", nil) }.to raise_error(Icons::IconNotFound)
  end
end
