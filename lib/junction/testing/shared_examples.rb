# frozen_string_literal: true

# Shared example for paginated index actions.
#
# @param path [Proc] Lambda returning the path to GET.
# @param model_class [Class, Proc] Either a model class (uses `.count`) or a
#   lambda evaluated in example context that returns the record count.
# @param factory [Symbol] FactoryBot factory name.
# @param opts_proc [Proc, nil] Optional lambda evaluated in example context
#   that returns a hash of factory options (e.g. `-> { { domain: domain } }`).
#   Use this for nested/association-based actions.
RSpec.shared_examples "a paginated index" do |path, model_class, factory, opts_proc = nil|
  describe "pagination" do
    let(:factory_opts) { opts_proc ? instance_exec(&opts_proc) : {} }
    let(:record_count) do
      model_class.is_a?(Proc) ? instance_exec(&model_class) : model_class.count
    end

    before { create_list(factory, total_records, **factory_opts) }

    let(:index_path) { instance_exec(&path) }
    let(:total_records) { 12 }

    it "defaults to 10 results per page" do
      get index_path
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "respects a valid per_page parameter" do
      get index_path, params: { per_page: 25 }
      expect(response.body.scan(/<tr/).length).to eq(record_count + 1)
    end

    it "falls back to the default for an invalid per_page value" do
      get index_path, params: { per_page: 999 }
      expect(response.body.scan(/<tr/).length).to eq(10 + 1)
    end

    it "returns the second page" do
      get index_path, params: { page: 2 }
      expect(response.body.scan(/<tr/).length).to eq((record_count - 10) + 1)
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
