# frozen_string_literal: true

describe Validation::Rule::Boolean do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect { validator.rule(:boolean, boolean: { param: true }) }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:boolean)
  end

  context "when validating" do
    before { stub_const("BooleanHolder", Struct.new(:boolean)) }

    context "strings" do
      it "validates boolean-esque strings" do
        %w[true false yes no t f y n 1 0].each do |str|
          validator = Validation::Validator.new(BooleanHolder.new(str))
          validator.rule(:boolean, :boolean)

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end
      end

      it "fails for non-boolean-esque strings" do
        validator = Validation::Validator.new(BooleanHolder.new("asdf"))
        validator.rule(:boolean, :boolean)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:boolean)
      end
    end

    context "numbers" do
      it "validates 0 and 1 to boolean" do
        [0, 1].each do |num|
          validator = Validation::Validator.new(BooleanHolder.new(num))
          validator.rule(:boolean, :boolean)

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end
      end

      it "fails for all other numbers" do
        validator = Validation::Validator.new(BooleanHolder.new(1234))
        validator.rule(:boolean, :boolean)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:boolean)
      end
    end

    context "boolean types" do
      it "validates true and false" do
        [true, false].each do |bln|
          validator = Validation::Validator.new(BooleanHolder.new(bln))
          validator.rule(:boolean, :boolean)

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end
      end
    end

    it "fails if nil or empty" do
      [nil, ""].each do |val|
        validator = Validation::Validator.new(BooleanHolder.new(val))
        validator.rule(:boolean, :boolean)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:boolean)
      end
    end
  end
end
