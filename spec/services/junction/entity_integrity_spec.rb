# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::EntityIntegrity do
  # These checks read the whole table, so the examples start from an empty one
  # and build exactly what they need. The per-example transaction rolls it back.
  before do
    Junction::Credential.delete_all
    Junction::Session.delete_all
    Junction::Identity.delete_all
    Junction::GroupMembership.delete_all
    Junction::RolePermission.delete_all
    Junction::Relation.delete_all
    Junction::Entity.update_all(
      owner_id: nil, system_id: nil, domain_id: nil,
      parent_id: nil, role_id: nil, location_id: nil
    )
    Junction::Entity.delete_all
  end

  let(:check_ids) { described_class.call.map { |problem| problem.check.id } }

  describe "sound data" do
    before do
      component = create(:component)
      create(:relation, source: component, target: create(:api))
      create(:group_membership, user: create(:user), group: create(:group))
    end

    it "reports no problems" do
      expect(described_class.call).to be_empty
    end
  end

  describe "references of the wrong kind" do
    it "detects an owner that is neither a group nor a user" do
      component = create(:component)
      component.update_column(:owner_id, create(:api).id)

      expect(problem_ids(:owner_kind)).to include(component.id)
    end

    it "accepts a user as an owner" do
      create(:component, owner: create(:user))

      expect(check_ids).not_to include(:owner_kind)
    end

    it "detects a system reference pointing at another kind" do
      component = create(:component)
      component.update_column(:system_id, create(:api).id)

      expect(problem_ids(:system_kind)).to include(component.id)
    end

    it "detects a parent of a different kind" do
      domain = create(:domain)
      domain.update_column(:parent_id, create(:group).id)

      expect(problem_ids(:parent_kind)).to include(domain.id)
    end

    it "detects a role held by something that is not a group" do
      system = create(:system)
      system.update_column(:role_id, create(:role).id)

      expect(problem_ids(:role_holder_kind)).to include(system.id)
    end
  end

  describe "unregistered kinds" do
    it "detects a kind the registry no longer knows" do
      component = create(:component)
      component.update_column(:kind, "Widget")

      expect(problem_ids(:unregistered_kind)).to include(component.id)
    end
  end

  describe "auth principals" do
    it "detects a session attached to something other than a user" do
      session = create(:user).sessions.create!
      session.update_column(:user_id, create(:group).id)

      expect(problem_ids(:session_owner)).to include(session.id)
    end

    it "detects a user with no credential" do
      user = create(:user)
      user.credential.delete

      expect(problem_ids(:missing_credential)).to include(user.id)
    end
  end

  describe "relations" do
    it "detects a target that cannot be depended on" do
      relation = create(:relation)
      relation.update_column(:target_id, create(:system).id)

      expect(problem_ids(:relation_target_kind)).to include(relation.id)
    end
  end

  describe Junction::EntityIntegrity::Problem do
    subject(:problem) do
      described_class.new(check:, count: 3, sample_ids: [ 1, 2 ])
    end

    let(:check) do
      Junction::EntityIntegrity::Check.new(id: :example, description: "broken things")
    end

    it "names the problem and some offending rows" do
      expect(problem.to_s).to eq("broken things: 3 row(s), e.g. 1, 2")
    end
  end

  # Rows reported by a named check.
  #
  # @param id [Symbol] The check's id.
  # @return [Array<Integer>] The reported IDs.
  def problem_ids(id)
    described_class.call.find { |problem| problem.check.id == id }&.sample_ids || []
  end
end
