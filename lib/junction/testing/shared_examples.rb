# frozen_string_literal: true

RSpec.shared_examples "a paginated index" do |path, model_class, factory|
  describe "pagination" do
    before { create_list(factory, total_records) }

    let(:index_path) { instance_exec(&path) }
    let(:total_records) { 12 }

    it "defaults to 10 results per page" do
      get index_path
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "respects a valid per_page parameter" do
      get index_path, params: { per_page: 25 }
      expect(response.body.scan(/<tr/).length).to eq(model_class.count + 1)
    end

    it "falls back to the default for an invalid per_page value" do
      get index_path, params: { per_page: 999 }
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "returns the second page" do
      get index_path, params: { page: 2 }
      expect(response.body.scan(/<tr/).length).to eq((model_class.count - 10) + 1)
    end

    context "when the total number of pages is greater than the ungapped max pages" do
      let(:total_records) { 100 }

      it "renders an ellipsis" do
        get index_path, params: { page: 1 }
        expect(response.body.scan(/<span>…<\/span>/).length).to eq(1)
      end
    end
  end
end
