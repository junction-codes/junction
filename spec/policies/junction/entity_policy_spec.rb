# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::EntityPolicy, type: :policy do
  let(:user) { build_stubbed(:user) }

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
