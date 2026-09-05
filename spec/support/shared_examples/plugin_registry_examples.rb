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

RSpec.shared_examples "context type handling" do |description, expected_result, invoke|
  let(:values) { { class: Junction::Domain, model: create(:domain), string: "Junction::Domain" } }

  %i[class model string].each do |context_type|
    it "returns #{description} when given a #{context_type}" do
      registry.register_plugin(plugin)

      expect(invoke.call(registry, values[context_type])).to eq(expected_result)
    end
  end
end
