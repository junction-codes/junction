# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::ReadableEntities do
  subject(:readable) { described_class.new(user:) }

  let(:catalog_kinds) { Junction::Kinds.catalog.select(&:exposed?) }

  def user_with(*permissions)
    person = create(:user)
    create(:group_membership, user: person,
                              group: create(:group, roles: [ create(:role, permissions:) ]))
    person
  end

  describe "#scope_for" do
    context "when the user may read every entity of a kind" do
      let(:user) { user_with("junction.codes/components.all.read") }

      it "returns the whole relation" do
        create(:component)

        expect(readable.scope_for(Junction::Component).count)
          .to eq(Junction::Component.count)
      end
    end

    context "when the user may only read what their groups own" do
      let(:owned) do
        create(:group,
               roles: [ create(:role, permissions: [ "junction.codes/components.owned.read" ]) ])
      end
      let(:user) { create(:user).tap { |u| create(:group_membership, user: u, group: owned) } }

      it "returns only the entities their groups own" do
        mine = create(:component, owner: owned)
        create(:component, owner: create(:group))

        expect(readable.scope_for(Junction::Component)).to contain_exactly(mine)
      end
    end

    context "when the user may read neither" do
      let(:user) { create(:user) }

      it "returns nothing to scope" do
        expect(readable.scope_for(Junction::Component)).to be_nil
      end
    end
  end

  describe "#scope_across" do
    let(:user) { user_with("junction.codes/components.all.read") }

    it "includes a kind the user may read" do
      component = create(:component)

      expect(readable.scope_across(catalog_kinds)).to include(component)
    end

    it "leaves out a kind the user may not read" do
      api = create(:api)

      expect(readable.scope_across(catalog_kinds)).not_to include(api)
    end

    context "when the user may read nothing" do
      let(:user) { create(:user) }

      it "is empty rather than unscoped" do
        create(:component)

        expect(readable.scope_across(catalog_kinds)).to be_empty
      end
    end
  end

  describe "#counts" do
    let(:user) do
      user_with("junction.codes/components.all.read", "junction.codes/apis.all.read")
    end

    # Counted as a delta rather than an absolute: the suite loads entity
    # fixtures, so the table is not empty.
    it "counts a readable kind" do
      expect { create_list(:component, 2) }
        .to change { described_class.new(user:).counts(catalog_kinds).fetch("Component", 0) }
        .by(2)
    end

    it "counts each readable kind separately" do
      expect { create(:api) }
        .to change { described_class.new(user:).counts(catalog_kinds).fetch("Api", 0) }
        .by(1)
    end

    it "leaves out a kind the user may not read" do
      create(:resource)

      expect(readable.counts(catalog_kinds)).not_to have_key("Resource")
    end

    it "asks the database once for a repeated question" do
      create(:component)
      readable.counts(catalog_kinds)

      expect { readable.counts(catalog_kinds) }.not_to make_database_queries
    end

    it "answers a different set of kinds separately" do
      create(:component)
      readable.counts(catalog_kinds)

      expect { readable.counts(catalog_kinds.first(1)) }.to make_database_queries
    end

    it "counts every kind in a single query" do
      expect { described_class.new(user:).counts(catalog_kinds) }
        .to make_database_queries(count: 1, matching: /COUNT\(\*\).*GROUP BY/)
    end
  end

  describe ".current" do
    let(:user) { create(:user) }

    before { Junction::Current.session = Junction::Session.create!(user:) }

    after { Junction::Current.reset }

    it "is the same instance for the length of a request" do
      first = described_class.current

      expect(described_class.current).to be(first)
    end

    it "is rebuilt once the session resumes and a user appears" do
      Junction::Current.reset
      before_sign_in = described_class.current
      Junction::Current.session = Junction::Session.create!(user:)

      expect(described_class.current).not_to be(before_sign_in)
    end

    it "reads the user from the current session" do
      expect(described_class.current.user).to eq(user)
    end
  end
end
