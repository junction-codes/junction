# frozen_string_literal: true

RSpec.shared_examples "plugin registration method with defaults" do |method_name, collection_name, default_keys|
  it "registers a #{method_name.to_s.tr('_', ' ')} with default values" do
    subject.public_send(method_name, **default_keys)

    expect(subject.public_send(collection_name)).not_to be_empty
  end
end

RSpec.shared_examples "plugin registration method with custom values" do |method_name, collection_name, custom_params|
  it "registers a #{method_name.to_s.tr('_', ' ')} with custom values" do
    subject.public_send(method_name, **custom_params)


    expect(subject.public_send(collection_name)).not_to be_empty
  end
end

RSpec.shared_examples "plugin registration method allows multiple" do |method_name, collection_name, first_params, second_params|
  it "registers multiple #{method_name.to_s.tr('_', ' ')}s" do
    subject.public_send(method_name, **first_params)
    subject.public_send(method_name, **second_params)

    expect(subject.public_send(collection_name).size).to eq(2)
  end
end
