# frozen_string_literal: true

RSpec.shared_examples "entity scope registration method allows multiple" do |method_name, collection_name, first_params, second_params|
  it "registers multiple #{method_name.to_s.tr('_', ' ')}s" do
    subject.public_send(method_name, **first_params)
    subject.public_send(method_name, **second_params)

    expect(subject.public_send(collection_name).size).to eq(2)
  end
end

RSpec.shared_examples "entity scope registration with condition" do |method_name, collection_name, params, condition_key|
  context "when a condition is provided" do
    let(:condition) { proc { true } }

    it "registers a #{method_name.to_s.tr('_', ' ')} with a condition" do
      subject.public_send(method_name, **params)
      item = subject.public_send(collection_name).first

      expect(item[condition_key]).to eq(condition)
    end
  end
end
