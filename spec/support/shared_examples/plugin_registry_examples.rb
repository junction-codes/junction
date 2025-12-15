# frozen_string_literal: true

RSpec.shared_examples "registry aggregation method" do |method_name, empty_value, params|
  context "with no registered #{method_name}" do
    it "returns empty #{empty_value.class.name.downcase} when no plugins are registered" do
      expect(registry.public_send(method_name, **params)).to eq(empty_value)
    end

    it "returns empty #{empty_value.class.name.downcase}" do
      registry.register_plugin(plugin)
      expect(registry.public_send(method_name, **params)).to eq(empty_value)
    end
  end
end

RSpec.shared_examples "context type handling" do |method_name, expected_result, params|
  let(:values) { { class: Domain, model: create(:domain), string: "Domain" } }

  %i[class model string].each do |context_type|
    it "returns #{method_name.to_s.tr('_', ' ')} when given a #{context_type}" do
      registry.register_plugin(plugin)

      expect(registry.public_send(method_name, **params.merge(context: values[context_type]))).to eq(expected_result)
    end
  end
end
