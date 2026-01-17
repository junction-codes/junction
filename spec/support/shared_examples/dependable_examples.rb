# frozen_string_literal: true

RSpec.shared_examples "a model that can be depended on" do
  describe 'dependable associations' do
    it { is_expected.to have_many(:dependents).dependent(:destroy) }
    it { is_expected.to have_many(:api_dependents).through(:dependents).source(:source) }
    it { is_expected.to have_many(:component_dependents).through(:dependents).source(:source) }
    it { is_expected.to have_many(:resource_dependents).through(:dependents).source(:source) }
  end

  describe 'dependable behavior' do
    let(:dependent_api) { create(:api) }
    let(:dependent_component) { create(:component) }
    let(:dependent_resource) { create(:resource) }

    it 'can be depended on by apis' do
      subject.save!
      create(:dependency, source: dependent_api, target: subject)
      expect(subject.api_dependents).to include(dependent_api)
    end

    it 'can be depended on by components' do
      subject.save!
      create(:dependency, source: dependent_component, target: subject)
      expect(subject.component_dependents).to include(dependent_component)
    end

    it 'can be depended on by resources' do
      subject.save!
      create(:dependency, source: dependent_resource, target: subject)
      expect(subject.resource_dependents).to include(dependent_resource)
    end

    it 'destroys dependency associations when destroyed' do
      subject.save!
      dependency = create(:dependency, source: dependent_api, target: subject)
      expect { subject.destroy }.to change { Junction::Dependency.exists?(dependency.id) }.from(true).to(false)
    end

    it 'does not destroy the dependent record when destroyed' do
      subject.save!
      create(:dependency, source: dependent_api, target: subject)
      expect { subject.destroy }.not_to change { Junction::Api.exists?(dependent_api.id) }.from(true)
    end
  end
end
