# frozen_string_literal: true

RSpec.shared_examples "a sluggable entity" do
  describe "slug auto-generation" do
    it "auto-generates name from title on create" do
      subject.title = "My Example Title"
      subject.name = nil
      subject.save!
      expect(subject.name).to eq("my-example-title")
    end

    it "does not overwrite a manually set name on create" do
      subject.title = "Some Title"
      subject.name = "custom-slug"
      subject.save!
      expect(subject.name).to eq("custom-slug")
    end
  end

  describe "namespace" do
    it "defaults namespace to 'default'" do
      expect(subject.namespace).to eq("default")
    end

    context "when namespace does not start with a lowercase letter" do
      before { subject.namespace = "1invalid" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes a namespace error" do
        subject.valid?
        expect(subject.errors[:namespace]).to be_present
      end
    end

    context "when namespace contains uppercase letters" do
      before { subject.namespace = "MyNamespace" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes a namespace error" do
        subject.valid?
        expect(subject.errors[:namespace]).to be_present
      end
    end

    context "when namespace exceeds 64 characters" do
      before { subject.namespace = "a" + ("b" * 64) }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes a namespace error" do
        subject.valid?
        expect(subject.errors[:namespace]).to be_present
      end
    end

    it "is valid with lowercase letters, numbers, and hyphens" do
      subject.namespace = "my-namespace-01"
      expect(subject).to be_valid
    end
  end

  describe "immutability" do
    before { subject.save! }

    context "when name is changed after creation" do
      before { subject.name = "changed-slug" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes an immutability error on name" do
        subject.valid?
        expect(subject.errors[:name]).to include("cannot be changed after creation.")
      end
    end

    context "when namespace is changed after creation" do
      before { subject.namespace = "new-namespace" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes an immutability error on namespace" do
        subject.valid?
        expect(subject.errors[:namespace]).to include("cannot be changed after creation.")
      end
    end

    it "is valid when name and namespace are unchanged on update" do
      subject.description = "Updated description"
      expect(subject).to be_valid
    end
  end

  describe "name format validation" do
    context "when name does not start with a letter" do
      before { subject.name = "1invalid" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes a name error" do
        subject.valid?
        expect(subject.errors[:name]).to be_present
      end
    end

    context "when name contains spaces" do
      before { subject.name = "invalid name" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end

      it "includes a name error" do
        subject.valid?
        expect(subject.errors[:name]).to be_present
      end
    end

    it "is valid with letters, numbers, hyphens, underscores, and dots" do
      subject.name = "valid-name.v1_ok"
      expect(subject).to be_valid
    end
  end
end
