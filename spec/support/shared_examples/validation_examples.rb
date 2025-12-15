# frozen_string_literal: true

RSpec.shared_examples "validates presence of" do |attribute|
  context "when #{attribute} is not present" do
    before { subject.public_send("#{attribute}=", nil) }

    it "is invalid without a #{attribute}" do
      expect(subject).not_to be_valid
    end

    it "includes presence error for #{attribute}" do
      subject.valid?
      expect(subject.errors[attribute]).to include("can't be blank")
    end
  end
end

RSpec.shared_examples "validates uniqueness of" do |attribute, duplicate_value = "Duplicate Value", scope: nil|
  context "when a record with the same #{attribute} exists" do
    let(:params) do
      p = { attribute => duplicate_value }
      p[scope] = subject.public_send(scope) if scope
      p
    end

    before do
      create(described_class.name.underscore.to_sym, params)
      subject.public_send("#{attribute}=", duplicate_value)
    end

    it "is invalid with a duplicate #{attribute}" do
      expect(subject).not_to be_valid
    end

    it "includes uniqueness error for #{attribute}" do
      subject.valid?
      expect(subject.errors[attribute]).to include("has already been taken")
    end
  end
end

RSpec.shared_examples "validates status inclusion" do
  context "when status is empty" do
    before { subject.status = nil }

    it "is invalid without" do
      expect(subject).not_to be_valid
    end

    it "includes presence error for status" do
      subject.valid?
      expect(subject.errors[:status]).to include("can't be blank")
    end
  end

  context "when status is an invalid value" do
    before { subject.status = "invalid_status" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "includes inclusion error for status" do
      subject.valid?
      expect(subject.errors[:status]).to include("is not included in the list")
    end
  end
end

RSpec.shared_examples "validates email format of" do |attribute, required: false|
  context "when the #{attribute} is valid" do
    it "is valid with a blank #{attribute}" do
      subject.public_send("#{attribute}=", "")
      expect(subject).to be_valid
    end

    it "is valid with a valid #{attribute}" do
      subject.public_send("#{attribute}=", "valid@example.com")
      expect(subject).to be_valid
    end
  end unless required

  context "when the #{attribute} is invalid" do
    before { subject.public_send("#{attribute}=", "invalid_email") }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "includes format error for #{attribute}" do
      subject.valid?
      expect(subject.errors[attribute]).to include("is invalid")
    end
  end
end

RSpec.shared_examples "validates image_url format" do
  context "when the image_url is valid" do
    it "is valid with a blank image_url" do
      subject.image_url = ""
      expect(subject).to be_valid
    end

    it "is valid with a valid http image_url" do
      subject.image_url = "http://example.com/image.png"
      expect(subject).to be_valid
    end

    it "is valid with a valid https image_url" do
      subject.image_url = "https://example.com/image.png"
      expect(subject).to be_valid
    end
  end

  context "when the image_url is invalid" do
    before { subject.image_url = "invalid_url" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "includes format error for image_url" do
      subject.valid?
      expect(subject.errors[:image_url]).to include("is invalid")
    end
  end
end

RSpec.shared_examples "has default status active" do
  it "defaults status to active" do
    expect(described_class.new.status).to eq("active")
  end
end
