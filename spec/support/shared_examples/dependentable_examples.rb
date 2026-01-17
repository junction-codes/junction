# frozen_string_literal: true

RSpec.shared_examples 'a model with dependencies' do
  describe 'dependentable associations' do
    it { is_expected.to have_many(:dependencies).dependent(:destroy) }
    it { is_expected.to have_many(:dependent_apis).through(:dependencies).source(:target) }
    it { is_expected.to have_many(:dependent_components).through(:dependencies).source(:target) }
    it { is_expected.to have_many(:dependent_resources).through(:dependencies).source(:target) }
  end

  describe 'dependentable behavior' do
    let(:api_dependency) { create(:api) }
    let(:component_dependency) { create(:component) }
    let(:resource_dependency) { create(:resource) }

    it 'can depend on apis' do
      subject.save!
      create(:dependency, source: subject, target: api_dependency)
      expect(subject.dependent_apis).to include(api_dependency)
    end

    it 'can depend on components' do
      subject.save!
      create(:dependency, source: subject, target: component_dependency)
      expect(subject.dependent_components).to include(component_dependency)
    end

    it 'can depend on resources' do
      subject.save!
      create(:dependency, source: subject, target: resource_dependency)
      expect(subject.dependent_resources).to include(resource_dependency)
    end

    it 'destroys dependency associations when destroyed' do
      subject.save!
      dependency = create(:dependency, source: subject, target: api_dependency)
      expect { subject.destroy }.to change { Junction::Dependency.exists?(dependency.id) }.from(true).to(false)
    end

    it 'does not destroy the target record when destroyed' do
      subject.save!
      create(:dependency, source: subject, target: api_dependency)
      expect { subject.destroy }.not_to change { Junction::Api.exists?(api_dependency.id) }.from(true)
    end
  end
end
