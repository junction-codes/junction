# frozen_string_literal: true

require "rails_helper"

RSpec.describe "An externally managed entity", type: :request do
  let(:component) do
    create(:component, title: "Payments API", managed_by: "location",
                       source_ref: "junction.yaml")
  end

  before do
    user = create_user_with_permissions(%w[junction.codes/components.all.read
                                           junction.codes/components.all.write
                                           junction.codes/components.all.destroy])
    sign_in(user:, password: "Password1!")
  end

  describe "its form" do
    before { get edit_component_path(component) }

    it "opens" do
      expect(response).to have_http_status(:ok)
    end

    it "says where the entity comes from" do
      expect(response.body).to include("comes from a Location")
    end

    it "names the file it came from" do
      expect(response.body).to include("junction.yaml")
    end

    it "disables every field at once" do
      expect(response.parsed_body.at_css("form fieldset[disabled]")).to be_present
    end

    it "offers nothing to save" do
      expect(response.parsed_body.at_css("form button[type='submit']")).to be_nil
    end

    it "still opens the metadata panes" do
      triggers = response.parsed_body.css("[data-ruby-ui--tabs-target='trigger']")

      expect(triggers).to be_present.and all(satisfy { |t| t.ancestors("fieldset[disabled]").empty? })
    end

    it "offers a way back" do
      expect(response.parsed_body.at_css("form a[href='#{component_path(component)}']"))
        .to be_present
    end

    it "does not offer to delete it" do
      expect(response.body).not_to include("Danger Zone")
    end
  end

  describe "deleting it anyway" do
    before { delete component_path(component) }

    it "is refused" do
      expect(flash[:alert]).to include("not authorized")
    end

    it "leaves the entity alone" do
      expect { component.reload }.not_to raise_error
    end
  end

  describe "its dependencies" do
    let(:target) { create(:component, title: "Ledger") }

    before do
      post component_dependencies_path(namespace: component.namespace, name: component.name),
           params: { dependency: { target: "Junction::Component:#{target.id}" } }
    end

    it "cannot be added" do
      expect(flash[:alert]).to include("not authorized")
    end

    it "stays empty" do
      expect(component.dependencies).to be_empty
    end
  end

  describe "an externally managed group" do
    let(:group) do
      create(:group, managed_by: "location", source_ref: "junction.yaml")
    end
    let(:member) { create(:user) }

    before do
      user = create_user_with_permissions(%w[junction.codes/groups.all.read
                                             junction.codes/groups.all.write
                                             junction.codes/users.all.read])

      sign_in(user:, password: "Password1!")

      post group_members_path(group), params: { member: { user_id: member.id } }
    end

    it "takes no new members" do
      expect(flash[:alert]).to include("not authorized")
    end

    it "stays empty" do
      expect(group.members).to be_empty
    end
  end

  describe "saving it anyway" do
    before do
      patch component_path(component), params: { component: { title: "Renamed" } }
    end

    it "is refused" do
      expect(response).to have_http_status(:see_other)
    end

    it "says so" do
      expect(flash[:alert]).to include("not authorized")
    end

    it "leaves the entity alone" do
      expect(component.reload.title).to eq("Payments API")
    end
  end

  describe "an entity of our own" do
    let(:component) { create(:component, title: "Payments API") }

    before { get edit_component_path(component) }

    it "has no banner" do
      expect(response.body).not_to include("Read-only")
    end

    it "can be saved" do
      expect(response.parsed_body.at_css("form button[type='submit']")).to be_present
    end
  end
end
