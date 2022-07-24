# frozen_string_literal: true

describe Validation::Rule::Guid do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect { validator.rule(:guid, guid: { param: true }) }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:guid)
  end

  context "when validating" do
    before { stub_const("GuidHolder", Struct.new(:guid)) }

    it "validates a string at least 16 chars long, consisting of [0-9a-f] (diaspora)" do
      validator = Validation::Validator.new(GuidHolder.new("abcdef0123456789"))
      validator.rule(:guid, :guid)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a long string with random characters and [-_@.:] (redmatrix)" do
      validator = Validation::Validator.new(GuidHolder.new("1234567890ABCDefgh_ijkl-mnopqrSTUVwxyz@example.com:3000"))
      validator.rule(:guid, :guid)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails if the string is too short" do
      validator = Validation::Validator.new(GuidHolder.new("012345"))
      validator.rule(:guid, :guid)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:guid)
    end

    it "fails if the string is too long" do
      validator = Validation::Validator.new(GuidHolder.new("a" * 256))
      validator.rule(:guid, :guid)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:guid)
    end

    it "fails if the string contains special chars at the end" do
      validator = Validation::Validator.new(GuidHolder.new("abcdef0123456789."))
      validator.rule(:guid, :guid)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:guid)
    end

    it "fails if the string contains invalid chars" do
      validator = Validation::Validator.new(GuidHolder.new("ghijklmnopqrstuvwxyz++"))
      validator.rule(:guid, :guid)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:guid)
    end

    it "fails if the string is empty" do
      [nil, ""].each do |val|
        validator = Validation::Validator.new(GuidHolder.new(val))
        validator.rule(:guid, :guid)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:guid)
      end
    end
  end
end
