# frozen_string_literal: true

require "rails_helper"

# Guards NOTICE.md against drifting from the files it attributes.
#
# Every vendored file carries a header comment declaring its package and
# version, written by `bin/importmap pin` for JavaScript and by hand for
# stylesheets. That header is the source of truth these examples compare
# NOTICE.md against, so vendoring a new package, dropping one, or bumping a
# version each fail until the notice is brought back in line.
#
# A dependency that relicenses without changing version is not detectable
# here. Any version change does fail, which is the prompt to re-read the
# upstream LICENSE while updating the table.
RSpec.describe "NOTICE.md" do # rubocop:disable RSpec/DescribeClass
  let(:notice) { root.join("NOTICE.md").read }

  def root
    Junction::Engine.root
  end

  def vendored_files
    Dir[
      root.join("vendor/javascript/*.js").to_s,
      root.join("vendor/stylesheets/*.css").to_s
    ].sort
  end

  def relative_path(file)
    Pathname(file).relative_path_from(root).to_s
  end

  # Headers look like `// cytoscape@3.34.1 downloaded from ...` for
  # importmap-managed JavaScript and `* tw-animate-css v1.4.0` for the
  # hand-vendored stylesheet.
  def declared_version(file)
    header = File.foreach(file).first(3).join

    header[/[@v](\d+\.\d+\.\d+)/, 1] ||
      raise("No package version header found in #{relative_path(file)}")
  end

  def notice_line_for(path)
    notice.lines.find { |line| line.include?(path) }.to_s
  end

  def unlisted_files
    vendored_files
      .map { |file| relative_path(file) }
      .reject { |path| notice.include?(path) }
  end

  def version_mismatches
    vendored_files.filter_map do |file|
      path = relative_path(file)
      version = declared_version(file)
      next if notice_line_for(path).include?(version)

      "#{path} declares #{version}, which its NOTICE.md row does not record"
    end
  end

  def stale_attributions
    referenced = notice.scan(%r{`(vendor/[^`]+)`}).flatten.uniq

    referenced.reject { |path| root.join(path).exist? }
  end

  it "attributes at least one vendored file" do
    expect(vendored_files).not_to be_empty
  end

  it "lists every vendored file" do
    expect(unlisted_files).to be_empty
  end

  it "records the version that each vendored file declares" do
    expect(version_mismatches).to be_empty
  end

  it "does not attribute files that are no longer vendored" do
    expect(stale_attributions).to be_empty
  end
end
