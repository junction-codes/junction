# frozen_string_literal: true

RSpec.shared_examples "a paginated index" do |path, model_class, factory|
  describe "pagination" do
    before { create_list(factory, 12) }

    let(:index_path) { instance_exec(&path) }

    it "defaults to 10 results per page" do
      get index_path
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "respects a valid per_page parameter" do
      total = model_class.count
      get index_path, params: { per_page: 25 }
      expect(response).to be_successful
      expect(response.body.scan(/<tr/).length).to eq(total + 1)
    end

    it "falls back to the default for an invalid per_page value" do
      get index_path, params: { per_page: 999 }
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "returns the second page" do
      total = model_class.count
      get index_path, params: { page: 2 }
      expect(response).to be_successful
      expect(response.body.scan(/<tr/).length).to eq((total - 10) + 1)
    end
  end
end
