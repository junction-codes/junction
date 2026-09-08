# frozen_string_literal: true

require "rails_helper"

# Automated accessibility checks over the screens the redesign touches.
#
# axe finds structural problems -- an input with no label, a control with no
# accessible name, color that does not meet contrast. It can't find
# behavioral ones.
RSpec.describe "Junction accessibility", :js, type: :system do
  # Rows the user can't act on, (e.g. "coming soon" nav entries, buttons the
  # user has no permission for) are dimmed with `opacity-50`, which puts their
  # text under the 4.5:1 contrast floor. The dimmed treatment is the designs,
  # and the rail it appears in is rebuilt in the shell phase, so the audit skips
  # those elements rather than the whole `color-contrast` rule.
  def audit
    be_axe_clean.excluding('[aria-disabled="true"]',
                           '[aria-disabled="true"] *')
  end

  let(:component) do
    create(:component, tags: %w[payments go], labels: { "tier" => "gold" },
                       links: [ { "url" => "https://runbook.example.com",
                                  "title" => "Runbook" } ])
  end

  before do
    sign_in_with_permissions(%w[
      junction.codes/dashboards.all.read
      junction.codes/components.all.read
      junction.codes/components.all.write
    ])
  end

  context "with the dashboard" do
    before { visit dashboard_path }

    it "has no violations" do
      expect(page).to audit
    end
  end

  context "with the catalog listing" do
    before { visit components_path }

    it "has no violations" do
      expect(page).to audit
    end
  end

  context "with an entity page" do
    before { visit component_path(component) }

    it "has no violations" do
      expect(page).to audit
    end
  end

  context "with the entity form" do
    before { visit edit_component_path(component) }

    it "has no violations" do
      expect(page).to audit
    end
  end
end
