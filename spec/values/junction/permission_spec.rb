# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Permission do
  subject(:permission) do
    described_class.new(domain: "junction.codes", context: "apis",
                        ownership: "all", access: "read")
  end

  let(:permission_string) { "junction.codes/apis.all.read" }

  describe ".parse" do
    context "when the string is valid" do
      it "returns an instance of Permission" do
        expect(described_class.parse(permission_string)).to be_a(described_class)
      end

      it "accepts the minimal valid format" do
        expect(described_class.parse("a/b.c.d")).to be_a(described_class)
      end
    end

    context "when the string is invalid" do
      it "returns nil when given nil" do
        expect(described_class.parse(nil)).to be_nil
      end

      it "returns nil when given an empty string" do
        expect(described_class.parse("")).to be_nil
      end

      it "returns nil for a string without a slash" do
        expect(described_class.parse("no-slash")).to be_nil
      end

      it "returns nil for a string with too many dot-separated segments" do
        expect(described_class.parse("too/many.dots.here.extra")).to be_nil
      end

      it "returns nil for a string with too few dot-separated segments" do
        expect(described_class.parse("missing/dots")).to be_nil
      end
    end
  end

  describe "#to_s" do
    it "returns the permission string in a valid format" do
      expect(permission.to_s).to eq(permission_string)
    end
  end

  describe "#id" do
    it "returns the value as a string" do
      expect(permission.id).to eq(permission_string)
    end
  end

  describe "#read?" do
    context "when access is read" do
      it "returns true" do
        expect(permission).to be_read
      end
    end

    context "when access is destroy" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "destroy")
      end

      it "returns false" do
        expect(permission).not_to be_read
      end
    end

    context "when access is write" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "write")
      end

      it "returns false" do
        expect(permission).not_to be_read
      end
    end
  end

  describe "#write?" do
    context "when access is read" do
      it "returns false" do
        expect(permission).not_to be_write
      end
    end

    context "when access is destroy" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "destroy")
      end

      it "returns false" do
        expect(permission).not_to be_write
      end
    end

    context "when access is write" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "write")
      end

      it "returns true" do
        expect(permission).to be_write
      end
    end
  end

  describe "#destroy?" do
   context "when access is read" do
      it "returns false" do
        expect(permission).not_to be_destroy
      end
    end

    context "when access is destroy" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "destroy")
      end

      it "returns true" do
        expect(permission).to be_destroy
      end
    end

    context "when access is write" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "all", access: "write")
      end

      it "returns false" do
        expect(permission).not_to be_destroy
      end
    end
  end

  describe "#all?" do
    context "when ownership is all" do
      it "returns true" do
        expect(permission).to be_all
      end
    end

    context "when ownership is owned" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "owned", access: "read")
      end

      it "returns false" do
        expect(permission).not_to be_all
      end
    end
  end

  describe "#owned?" do
    context "when ownership is all" do
      it "returns false" do
        expect(permission).not_to be_owned
      end
    end

    context "when ownership is owned" do
      subject(:permission) do
        described_class.new(domain: "junction.codes", context: "apis",
                            ownership: "owned", access: "read")
      end

      it "returns true" do
        expect(permission).to be_owned
      end
    end
  end

  describe "#==" do
    context "when compared to an equivalent permission" do
      it "returns true when the other permission is the same string" do
        expect(permission).to eq(described_class.parse(permission_string))
      end
    end

    context "when compared to a different permission" do
      it "returns false" do
        expect(permission).not_to eq(described_class.parse("junction.codes/apis.all.write"))
      end

      it "returns false when comparing to a string" do
        expect(permission).not_to eq(permission_string)
      end

      it "returns false when comparing to nil" do
        expect(permission).not_to eq(nil) # rubocop:disable RSpec/BeEq
      end
    end
  end

  describe "#hash" do
    it "returns the same hash for equivalent permissions" do
      expect(permission.hash).to eq(described_class.parse(permission_string).hash)
    end

    it "deduplicates equal permissions in a Set" do
      set = Set[
        permission,
        described_class.parse(permission_string),
        described_class.parse("junction.codes/apis.all.write")
      ]

      expect(set.size).to eq(2)
    end

    it "allows equal permissions to be found in a Set" do
      set = Set[described_class.parse(permission_string)]

      expect(set).to include(described_class.parse(permission_string))
    end
  end
end
