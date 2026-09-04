# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::EntityPolicy, type: :policy do
  let(:user) { build_stubbed(:user) }

  before do
    stub_const("MyPlugin::Widget", Class.new(Junction::Entity))
    Junction::Kinds.register(:widget, model_name: "MyPlugin::Widget",
                                      domain: "example.com")
  end

  after { Junction::Kinds.reset! }

  describe "#context" do
    Junction::Kinds.all.each do |kind|
      it "derives #{kind.context.inspect} for #{kind.name}" do
        policy = described_class.new(kind.model.new, user:)
        expect(policy.context).to eq(kind.context)
      end

      it "derives #{kind.context.inspect} when given the #{kind.name} class" do
        policy = described_class.new(kind.model, user:)
        expect(policy.context).to eq(kind.context)
      end
    end

    context "when the record's kind is not registered" do
      it "raises rather than silently denying every permission" do
        policy = described_class.new(Junction::Entity.new, user:)
        expect { policy.context }.to raise_error(ArgumentError, /No registered kind/)
      end
    end
  end

  describe "#domain" do
    it "is the core domain for a core kind" do
      policy = described_class.new(Junction::Api.new, user:)
      expect(policy.domain).to eq(Junction::CorePlugin::DOMAIN)
    end

    it "is the kind's domain for a kind a plugin registered" do
      policy = described_class.new(MyPlugin::Widget.new, user:)
      expect(policy.domain).to eq("example.com")
    end
  end

  describe "authorization for a kind registered under a plugin's domain" do
    subject(:policy) { described_class.new(MyPlugin::Widget.new, user:) }

    let(:user) do
      build_stubbed(:user) { |u| allow(u).to receive(:deep_group_ids).and_return([]) }
    end

    let(:permissions) do
      instance_double(Junction::Permissions::UserPermissions, has_permission?: false)
    end

    before do
      allow(Junction::Permissions::UserPermissions).to receive(:new)
        .with(user).and_return(permissions)
    end

    it "grants on a permission in the plugin's own domain" do
      allow(permissions).to receive(:has_permission?)
        .with("example.com/widgets.all.read").and_return(true)

      expect(policy.show?).to be(true)
    end

    it "ignores the same context under the core domain" do
      allow(permissions).to receive(:has_permission?)
        .with("#{Junction::CorePlugin::DOMAIN}/widgets.all.read").and_return(true)

      expect(policy.show?).to be(false)
    end
  end

  describe "policy resolution" do
    Junction::Kinds.all.each do |kind|
      it "resolves #{kind.name} to this policy" do
        expect(kind.model.policy_class).to eq(described_class)
      end
    end
  end

  context "with an API record" do
    let(:record) { build_stubbed(:api) }
    let(:policy) { described_class.new(record, user:) }

    it_behaves_like "an application policy with context", "apis"
  end
end
