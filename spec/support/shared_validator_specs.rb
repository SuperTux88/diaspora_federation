# frozen_string_literal: true

def entity_stub(entity, data = {})
  entity_class = Fabricate.schematic(entity).options[:class_name]
  allow_any_instance_of(entity_class).to receive(:freeze)
  allow_any_instance_of(entity_class).to receive(:validate)
  entity_class.new(Fabricate.attributes_for(entity).merge(data))
end

ALPHANUMERIC_RANGE = [*"0".."9", *"A".."Z", *"a".."z"].freeze

def alphanumeric_string(length)
  Array.new(length) { ALPHANUMERIC_RANGE.sample }.join
end

shared_examples "a common validator" do
  it "validates a well-formed instance" do
    validator = described_class.new(entity_stub(entity))
    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end
end

shared_examples "a relayable validator" do
  it_behaves_like "a diaspora* ID validator" do
    let(:property) { :author }
  end

  describe "#guid" do
    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end
  end

  describe "#parent_guid" do
    it_behaves_like "a guid validator" do
      let(:property) { :parent_guid }
    end
  end

  describe "#parent" do
    it_behaves_like "a property with a value validation/restriction" do
      let(:property) { :parent }
      let(:wrong_values) { [nil] }
      let(:correct_values) { [Fabricate(:related_entity)] }
    end
  end
end

shared_examples "a property with a value validation/restriction" do
  it "fails if a wrong value is supplied" do
    wrong_values.each do |val|
      validator = described_class.new(entity_stub(entity, property => val))
      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end

  it "validates if a correct value is supplied" do
    correct_values.each do |val|
      validator = described_class.new(entity_stub(entity, property => val))
      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end
end

shared_examples "a property that mustn't be empty" do
  it_behaves_like "a property with a value validation/restriction" do
    let(:wrong_values) { ["", nil] }
    let(:correct_values) { [] }
  end
end

shared_examples "a diaspora* ID validator" do
  it "must not be nil or empty if mandatory" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end

  it "validates a well-formed diaspora* ID" do
    validator = described_class.new(entity_stub(entity, property => "alice@example.org"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must be a valid diaspora* ID" do
    validator = described_class.new(entity_stub(entity, property => "i am a weird diaspora* ID @@@ ### 12345"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "common guid validator" do
  it "validates a well-formed guid from redmatrix" do
    validator = described_class.new(entity_stub(entity, property => "1234567890ABCDefgh_ijkl-mnopQR@example.com:3000"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must be at least 16 chars" do
    validator = described_class.new(entity_stub(entity, property => "aaaaaa"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must only contain [0-9a-z-_@.:]" do
    validator = described_class.new(entity_stub(entity, property => "zzz+-#*$$"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a guid validator" do
  include_examples "common guid validator"

  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a nilable guid validator" do
  include_examples "common guid validator"

  it "can be nil" do
    validator = described_class.new(entity_stub(entity, property => nil))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end
end

shared_examples "a boolean validator" do
  it "validates a well-formed boolean" do
    [true, "true", false, "false"].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "must not be an arbitrary string or other object" do
    ["asdf", Date.today, 1234].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a public key validator" do
  it "fails for malformed rsa key" do
    validator = described_class.new(entity_stub(entity, property => "ASDF"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a name validator" do
  it "is allowed to be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "is allowed to contain special chars" do
    validator = described_class.new(entity_stub(entity, property => "cool name ©"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "validates the maximum number of chars" do
    validator = described_class.new(entity_stub(entity, property => alphanumeric_string(length)))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must not exceed the maximum number of chars" do
    validator = described_class.new(entity_stub(entity, property => alphanumeric_string(length + 1)))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not contain semicolons" do
    validator = described_class.new(entity_stub(entity, property => "asdf;qwer;yxcv"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a length validator" do
  it "is allowed to be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "is allowed to contain special chars" do
    validator = described_class.new(entity_stub(entity, property => "cool name ©;:#%"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "validates the maximum number of chars" do
    validator = described_class.new(entity_stub(entity, property => alphanumeric_string(length)))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must not exceed the maximum number of chars" do
    validator = described_class.new(entity_stub(entity, property => alphanumeric_string(length + 1)))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a url validator without path" do
  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property => val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end

  it "fails for url with special chars" do
    validator = described_class.new(entity_stub(entity, property => "https://asdf$%.com"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "fails for url without scheme" do
    validator = described_class.new(entity_stub(entity, property => "example.com"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a url path validator" do
  it "validates url with a path" do
    validator = described_class.new(entity_stub(entity, property => "https://example.com/some/path"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "fails for url with special chars" do
    validator = described_class.new(entity_stub(entity, property => "https://asdf$%.com/some/path"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "fails for url without path" do
    validator = described_class.new(entity_stub(entity, property => "https://example.com"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end
