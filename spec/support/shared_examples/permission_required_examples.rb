# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "an action that requires permission" do |http_method, path, permissions, params = {}|
  context "when the user lacks permission" do
    before do
      sign_in_unauthorized_user
      send(
        http_method,
        path.is_a?(Proc) ? instance_exec(&path) : path,
        params: params.is_a?(Proc) ? instance_exec(&params) : params
      )
    end

    it "returns a 303 status" do
      expect(response).to have_http_status(:see_other)
    end

    it "redirects to the root path" do
      expect(response).to redirect_to(root_path)
    end

    it "sets an alert message" do
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end

  context "when the user has the required permission" do
    before do
      sign_in_user_with_permissions(permissions)
      send(
        http_method,
        path.is_a?(Proc) ? instance_exec(&path) : path,
        params: params.is_a?(Proc) ? instance_exec(&params) : params
      )
    end

    it "returns a successful status" do
      expect(response).to be_successful.or have_http_status(:see_other).or have_http_status(:found)
    end
  end
end
