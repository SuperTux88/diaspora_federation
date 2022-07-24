# frozen_string_literal: true

describe Validation::Rule::PublicKey do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:key, public_key: { param: true })
    }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:public_key)
  end

  context "when validating" do
    before do
      stub_const("PublicKeyHolder", Struct.new(:key))
    end

    ["PUBLIC KEY", "RSA PUBLIC KEY"].each do |key_type|
      context key_type do
        let(:prefix) { "-----BEGIN #{key_type}-----" }
        let(:suffix) { "-----END #{key_type}-----" }

        let(:key) { "#{prefix}\nAAAAAA==\n#{suffix}\n" }

        it "validates an exported RSA key" do
          validator = Validation::Validator.new(PublicKeyHolder.new(key))
          validator.rule(:key, :public_key)

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end

        it "strips whitespace" do
          validator = Validation::Validator.new(PublicKeyHolder.new("  \n   #{key}\n \n  "))
          validator.rule(:key, :public_key)

          expect(validator).to be_valid
          expect(validator.errors).to be_empty
        end

        it "fails if the prefix is missing" do
          validator = Validation::Validator.new(PublicKeyHolder.new("\nAAAAAA==\n#{suffix}\n"))
          validator.rule(:key, :public_key)

          expect(validator).not_to be_valid
          expect(validator.errors).to include(:key)
        end

        it "fails if the suffix is missing" do
          validator = Validation::Validator.new(PublicKeyHolder.new("#{prefix}\nAAAAAA==\n\n"))
          validator.rule(:key, :public_key)

          expect(validator).not_to be_valid
          expect(validator.errors).to include(:key)
        end

        it "fails if the key is nil or empty" do
          [nil, ""].each do |val|
            validator = Validation::Validator.new(PublicKeyHolder.new(val))
            validator.rule(:key, :public_key)

            expect(validator).not_to be_valid
            expect(validator.errors).to include(:key)
          end
        end
      end
    end
  end
end
