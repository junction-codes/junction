# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::CatalogEntityActions do
  let(:controllers) do
    [
      Junction::ApisController,
      Junction::ComponentsController,
      Junction::DomainsController,
      Junction::GroupsController,
      Junction::ResourcesController,
      Junction::SystemsController,
      Junction::UsersController
    ]
  end

  describe "the contract every catalog controller satisfies" do
    it "is included by each catalog controller" do
      expect(controllers).to all(include(described_class))
    end

    it "resolves a registered kind for each controller" do
      kinds = controllers.map { |c| Junction::Kinds.for(c.new.send(:entity_class).sti_name) }
      expect(kinds).to all(be_present)
    end

    it "defines create_params on each controller" do
      overrides = controllers.map do |controller|
        controller.private_instance_methods(false).include?(:create_params)
      end
      expect(overrides).to all(be(true))
    end

    it "provides the seven shared actions" do
      expect(Junction::ApisController.new).to respond_to(
        :index, :show, :new, :edit, :create, :update, :destroy
      )
    end
  end
end
