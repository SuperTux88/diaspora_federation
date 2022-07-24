# frozen_string_literal: true

require "json-schema"

def entity_hash_from(hash)
  hash.transform_values do |value|
    if [String, TrueClass, FalseClass, Integer, NilClass].any? { |c| value.is_a? c }
      value
    elsif value.is_a? Time
      value.iso8601
    elsif value.instance_of?(Array)
      value.map(&:to_h)
    else
      value.to_h
    end
  end
end

shared_examples "an Entity subclass" do
  it "should be an Entity" do
    expect(described_class).to be < DiasporaFederation::Entity
  end

  it "has its properties set" do
    expect(described_class.class_props.keys).to include(*data.keys)
  end

  context "behaviour" do
    let(:instance) { described_class.new(data) }

    describe "initialize" do
      it "must not create blank instances" do
        expect { described_class.new({}) }.to raise_error DiasporaFederation::Entity::ValidationError
      end

      it "fails if nil was given" do
        expect { described_class.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end

      it "should be frozen" do
        expect(instance).to be_frozen
      end
    end

    describe "#to_h" do
      it "should return a hash with nested data" do
        expect(instance.to_h).to eq(entity_hash_from(data))
      end
    end

    describe "#to_s" do
      it "should represent the entity as string" do
        expect(instance.to_s).to eq(string)
      end
    end
  end
end

shared_examples "an XML Entity" do |ignored_props = []|
  let(:instance) { described_class.new(data) }

  describe "#to_xml" do
    it "produces correct XML" do
      expect(instance.to_xml.to_s.strip).to eq(xml.strip)
    end
  end

  context "parsing" do
    it "reads its own output" do
      packed_xml = instance.to_xml
      parsed_instance = DiasporaFederation::Entity.entity_class(packed_xml.name).from_xml(packed_xml)

      check_entity(instance, parsed_instance, ignored_props)
    end
  end

  def check_entity(entity, parsed_entity, ignored_props)
    entity.class.class_props.reject { |name| ignored_props.include?(name) }.each do |name, type|
      validate_values(entity.send(name), parsed_entity.send(name), type, ignored_props)
    end
  end

  def validate_values(value, parsed_value, type, ignored_props)
    if value.nil?
      expect(parsed_value).to be_nil
    elsif type.instance_of?(Symbol)
      validate_property(value, parsed_value)
    elsif type.instance_of?(Array)
      value.each_with_index { |entity, index| check_entity(entity, parsed_value[index], ignored_props) }
    elsif type.ancestors.include?(DiasporaFederation::Entity)
      check_entity(value, parsed_value, ignored_props)
    end
  end

  def validate_property(value, parsed_value)
    if value.is_a?(Time)
      expect(parsed_value).to eq(change_time(value))
    else
      expect(parsed_value).to eq(value)
    end
  end
end

shared_examples "a relayable Entity" do
  let(:instance) { described_class.new(data.merge(author_signature: nil)) }

  context "signatures generation" do
    def verify_signature(pubkey, signature, signed_string)
      pubkey.verify(OpenSSL::Digest.new("SHA256"), Base64.decode64(signature), signed_string)
    end

    it "computes correct author_signature for the entity" do
      order = described_class.class_props.keys - %i[author_signature parent]
      signed_string = order.map { |name| data[name].is_a?(Time) ? data[name].iso8601 : data[name] }.join(";")

      author_signature = instance.to_xml.at_xpath("author_signature").text
      expect(verify_signature(alice.public_key, author_signature, signed_string)).to be_truthy
    end
  end
end

shared_examples "a JSON Entity" do
  describe "#to_json" do
    it "#to_json output matches JSON schema" do
      json = described_class.new(data).to_json
      errors = JSON::Validator.fully_validate("lib/diaspora_federation/schemas/federation_entities.json", json.to_json)
      expect(errors).to be_empty
    end

    let(:to_json_output) { described_class.new(data).to_json.to_json }

    it "contains described_class property matching the entity class (underscored)" do
      expect(to_json_output).to include_json(entity_type: described_class.entity_name)
    end

    it "contains JSON properties for each of the entity properties with the entity_data property" do
      entity_data = entity_hash_from(data)
      entity_data.delete(:parent)
      nested_elements, simple_props = entity_data.partition { |_key, value| value.is_a?(Array) || value.is_a?(Hash) }

      expect(to_json_output).to include_json(entity_data: simple_props.to_h.compact)

      nested_elements.each do |key, value|
        type = described_class.class_props[key]
        if value.is_a?(Array)
          data = value.map do |element|
            {
              entity_type: type.first.entity_name,
              entity_data: element
            }
          end
          expect(to_json_output).to include_json(entity_data: { key => data })
        else
          expect(to_json_output).to include_json(
            entity_data: {
              key => {
                entity_type: type.entity_name,
                entity_data: value
              }
            }
          )
        end
      end
    end

    it "produces correct JSON" do
      entity_json = JSON.pretty_generate(described_class.new(data).to_json)
      expect(entity_json).to eq(json.strip)
    end
  end

  it ".from_json(entity_json).to_json should match entity.to_json" do
    entity_json = described_class.new(data).to_json.to_json
    expect(described_class.from_json(JSON.parse(entity_json)).to_json.to_json).to eq(entity_json)
  end
end

shared_examples "a relayable JSON entity" do
  it "matches JSON schema with empty string signatures" do
    json = described_class.new(data).to_json
    json[:entity_data][:author_signature] = ""
    errors = JSON::Validator.fully_validate("lib/diaspora_federation/schemas/federation_entities.json", json.to_json)
    expect(errors).to be_empty
  end
end
