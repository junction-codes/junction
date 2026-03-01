# frozen_string_literal: true

RSpec.shared_examples "an application policy with context" do |context_value|
  describe "#context" do
    it "returns #{context_value.inspect}" do
      expect(policy.context).to eq(context_value)
    end
  end

  describe "rule delegation" do
    let(:user_permissions) do
      instance_double(Junction::Permissions::UserPermissions, has_permission?: false)
    end

    before do
      allow(Junction::Permissions::UserPermissions).to receive(:new).and_return(user_permissions)
    end

    it "responds to index?, show?, create?, update?, destroy?" do
      expect(policy).to respond_to(:index?, :show?, :create?, :update?, :destroy?)
    end

    it "allows edit? via alias to update?" do
      expect(policy.apply(:edit?)).to eq(policy.apply(:update?))
    end
  end
end
