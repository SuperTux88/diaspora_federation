# frozen_string_literal: true

describe Validation::Rule::NotNil do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:not_nil, not_nil: { param: true })
    }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:not_nil)
  end

  context "when validating" do
    before do
      stub_const("ValueHolder", Struct.new(:value))
    end

    it "validates a string" do
      validator = Validation::Validator.new(ValueHolder.new("abcd"))
      validator.rule(:value, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a object" do
      validator = Validation::Validator.new(ValueHolder.new(Object.new))
      validator.rule(:value, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails if it is nil" do
      validator = Validation::Validator.new(ValueHolder.new(nil))
      validator.rule(:value, :not_nil)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:value)
    end

    it "allows an empty string" do
      validator = Validation::Validator.new(ValueHolder.new(""))
      validator.rule(:value, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end
end
