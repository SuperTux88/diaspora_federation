# frozen_string_literal: true

module DiasporaFederation
  # +Entity+ is the base class for all other objects used to encapsulate data
  # for federation messages in the diaspora* network.
  # Entity fields are specified using a simple {PropertiesDSL DSL} as part of
  # the class definition.
  #
  # Any entity also provides the means to serialize itself and all nested
  # entities to XML (for deserialization from XML to +Entity+ instances, see
  # {Salmon::XmlPayload}).
  #
  # @abstract Subclass and specify properties to implement various entities.
  #
  # @example Entity subclass definition
  #   class MyEntity < Entity
  #     property :prop
  #     property :optional, default: false
  #     property :dynamic_default, default: -> { Time.now }
  #     entity :nested, NestedEntity
  #     entity :multiple, [OtherEntity]
  #   end
  #
  # @example Entity instantiation
  #   nentity = NestedEntity.new
  #   oe1 = OtherEntity.new
  #   oe2 = OtherEntity.new
  #
  #   entity = MyEntity.new(prop: 'some property',
  #                         nested: nentity,
  #                         multiple: [oe1, oe2])
  #
  # @note Entity properties can only be set during initialization, after that the
  #   entity instance becomes frozen and must not be modified anymore. Instances
  #   are intended to be immutable data containers, only.
  class Entity
    extend PropertiesDSL
    include Logging

    # Invalid XML characters
    # @see https://www.w3.org/TR/REC-xml/#charsets "Extensible Markup Language (XML) 1.0"
    INVALID_XML_REGEX = /[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u{10000}-\u{10FFFF}]/.freeze

    # Regex to validate and find entity names
    ENTITY_NAME_REGEX = "[a-z]*(?:_[a-z]*)*"

    # Initializes the Entity with the given attribute hash and freezes the created
    # instance it returns.
    #
    # After creation, the entity is validated against a Validator, if one is defined.
    # The Validator needs to be in the {DiasporaFederation::Validators} namespace and
    # named like "<EntityName>Validator". Only valid entities can be created.
    #
    # @see DiasporaFederation::Validators
    #
    # @note Attributes not defined as part of the class definition ({PropertiesDSL#property},
    #       {PropertiesDSL#entity}) get discarded silently.
    #
    # @param [Hash] data entity data
    # @return [Entity] new instance
    def initialize(data)
      logger.debug "create entity #{self.class} with data: #{data}"
      raise ArgumentError, "expected a Hash" unless data.is_a?(Hash)

      entity_data = self.class.resolv_aliases(data)
      validate_missing_props(entity_data)

      self
        .class
        .default_values
        .merge(entity_data)
        .each do |name, value|
          instance_variable_set("@#{name}", instantiate_nested(name, nilify(value))) if setable?(name, value)
        end

      freeze
      validate
    end

    # Returns a Hash representing this Entity (attributes => values).
    # Nested entities are also converted to a Hash.
    # @return [Hash] entity data (mostly equal to the hash used for initialization).
    def to_h
      enriched_properties.to_h do |key, value|
        type = self.class.class_props[key]

        if type.instance_of?(Symbol) || value.nil?
          [key, value]
        elsif type.instance_of?(Class)
          [key, value.to_h]
        elsif type.instance_of?(Array)
          [key, value.map(&:to_h)]
        end
      end
    end

    # Returns the XML representation for this entity constructed out of
    # {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Element Nokogiri::XML::Element}s
    #
    # @see Nokogiri::XML::Node.to_xml
    #
    # @return [Nokogiri::XML::Element] root element containing properties as child elements
    # prettier-ignore
    def to_xml
      doc = Nokogiri::XML::Document.new
      Nokogiri::XML::Element.new(self.class.entity_name, doc).tap do |root_element|
        xml_elements.each do |name, value|
          add_property_to_xml(doc, root_element, name, value)
        end
      end
    end

    # Construct a new instance of the given Entity and populate the properties
    # with the attributes found in the XML.
    # Works recursively on nested Entities and Arrays thereof.
    #
    # @param [Nokogiri::XML::Element] root_node xml nodes
    # @return [Entity] instance
    def self.from_xml(root_node)
      from_hash(*xml_parser_class.new(self).parse(root_node))
    end

    private_class_method def self.xml_parser_class
      DiasporaFederation::Parsers::XmlParser
    end

    # Creates an instance of self by parsing a hash in the format of JSON serialized object (which usually means
    # data from a parsed JSON input).
    def self.from_json(json_hash)
      from_hash(*json_parser_class.new(self).parse(json_hash))
    end

    private_class_method def self.json_parser_class
      DiasporaFederation::Parsers::JsonParser
    end

    # Makes an underscored, lowercase form of the class name
    #
    # @see .entity_class
    #
    # @return [String] entity name
    def self.entity_name
      class_name.tap do |word|
        word.gsub!(/(.)([A-Z])/, '\1_\2')
        word.downcase!
      end
    end

    # Transform the given String from the lowercase underscored version to a
    # camelized variant and returns the Class constant.
    #
    # @see .entity_name
    #
    # @param [String] entity_name "snake_case" class name
    # @return [Class] entity class
    def self.entity_class(entity_name)
      raise InvalidEntityName, "'#{entity_name}' is invalid" unless entity_name =~ /\A#{ENTITY_NAME_REGEX}\z/

      class_name = entity_name.sub(/\A[a-z]/, &:upcase)
      class_name.gsub!(/_([a-z])/) { Regexp.last_match[1].upcase }

      raise UnknownEntity, "'#{class_name}' not found" unless Entities.const_defined?(class_name)

      Entities.const_get(class_name)
    end

    # @return [String] class name as string
    def self.class_name
      name.rpartition("::").last
    end

    # @return [String] string representation of this object
    def to_s
      "#{self.class.class_name}#{":#{guid}" if respond_to?(:guid)}"
    end

    # Renders entity to a hash representation of the entity JSON format
    # @return [Hash] Returns a hash that is equal by structure to the entity in JSON format
    def to_json(*_args)
      { entity_type: self.class.entity_name, entity_data: json_data }
    end

    # Creates an instance of self, filling it with data from a provided hash of properties.
    #
    # The hash format is described as following:<br>
    # 1) Properties of the hash are representation of the entity's class properties<br>
    # 2) Keys of the hash must be of Symbol type<br>
    # 3) Possible values of the hash properties depend on the types of the entity's class properties<br>
    # 4) Basic properties, such as booleans, strings, integers and timestamps are represented by values of respective
    # formats<br>
    # 5) Nested hashes and arrays of hashes are allowed to represent nested entities. Nested hashes follow the same
    # format as the parent hash.<br>
    # 6) Besides, the nested entities can be passed in the hash as already instantiated objects of the respective type.
    #
    # @param [Hash] properties_hash A hash of the expected format
    # @return [Entity] an instance
    def self.from_hash(properties_hash)
      new(properties_hash)
    end

    private

    def validate_missing_props(entity_data)
      missing_props = self.class.missing_props(entity_data)
      return if missing_props.empty?

      obj_str =
        "#{self.class.class_name}#{":#{entity_data[:guid]}" if entity_data.has_key?(:guid)}" \
          "#{" from #{entity_data[:author]}" if entity_data.has_key?(:author)}"
      raise ValidationError, "#{obj_str}: Missing required properties: #{missing_props.join(", ")}"
    end

    def setable?(name, val)
      type = self.class.class_props[name]
      return false if type.nil? # property undefined

      setable_property?(type, val) || setable_nested?(type, val) || setable_multi?(type, val)
    end

    def setable_property?(type, val)
      setable_string?(type, val) || (type == :timestamp && val.is_a?(Time))
    end

    def setable_string?(type, val)
      %i[string integer boolean].include?(type) && val.respond_to?(:to_s)
    end

    def setable_nested?(type, val)
      type.instance_of?(Class) && type.ancestors.include?(Entity) && (val.is_a?(Entity) || val.is_a?(Hash))
    end

    def setable_multi?(type, val)
      type.instance_of?(Array) && val.instance_of?(Array) &&
        (val.all? { |v| v.instance_of?(type.first) } || val.all? { |v| v.instance_of?(Hash) })
    end

    def nilify(value)
      return nil if value.respond_to?(:empty?) && value.empty? && !value.instance_of?(Array)

      value
    end

    def instantiate_nested(name, value)
      if value.instance_of?(Array)
        return value unless value.first.instance_of?(Hash)

        value.map { |hash| self.class.class_props[name].first.new(hash) }
      elsif value.instance_of?(Hash)
        self.class.class_props[name].new(value)
      else
        value
      end
    end

    def validate
      validator_name = "#{self.class.name.split("::").last}Validator"
      return unless Validators.const_defined? validator_name

      validator_class = Validators.const_get validator_name
      validator = validator_class.new self
      raise ValidationError, error_message(validator) unless validator.valid?
    end

    def error_message(validator)
      errors =
        validator.errors.map do |prop, rule|
          "property: #{prop}, value: #{public_send(prop).inspect}, rule: #{rule[:rule]}, with params: #{rule[:params]}"
        end
      "Failed validation for #{self}#{" from #{author}" if respond_to?(:author)} for properties: #{errors.join(" | ")}"
    end

    # @return [Hash] hash with all properties
    def properties
      self.class.class_props.keys.each_with_object({}) { |prop, hash| hash[prop] = public_send(prop) }
    end

    def normalized_properties
      properties.to_h { |name, value| [name, normalize_property(name, value)] }
    end

    def normalize_property(name, value)
      return nil if optional_nil_value?(name, value)

      case self.class.class_props[name]
      when :string
        value.to_s.gsub(INVALID_XML_REGEX, "\uFFFD")
      when :timestamp
        value.nil? ? "" : value.utc.iso8601
      else
        value
      end
    end

    # default: nothing to enrich
    def enriched_properties
      normalized_properties
    end

    # default: no special order
    def xml_elements
      enriched_properties
    end

    def add_property_to_xml(doc, root_element, name, value)
      if [String, TrueClass, FalseClass, Integer].any? { |c| value.is_a? c }
        root_element << simple_node(doc, name, value.to_s)
      else
        # call #to_xml for each item and append to root
        [*value].compact.each do |item|
          child = item.to_xml
          root_element << child if child
        end
      end
    end

    # Create simple node, fill it with text and append to root
    # prettier-ignore
    def simple_node(doc, name, value)
      # prettier-ignore-start
      Nokogiri::XML::Element.new(name.to_s, doc).tap do |node|
        node.content = value unless value.empty?
      end
      # prettier-ignore-end
    end

    # Generates a hash with entity properties which is put to the "entity_data"
    # field of a JSON serialized object.
    # @return [Hash] object properties in JSON format
    def json_data # rubocop:disable Metrics/PerceivedComplexity
      data =
        enriched_properties.map do |key, value|
          type = self.class.class_props[key]
          next if optional_nil_value?(key, value)

          if !value.nil? && type.instance_of?(Class)
            entity_data = value.to_json
            [key, entity_data] unless entity_data.nil?
          elsif type.instance_of?(Array)
            entity_data = value&.map(&:to_json)
            [key, entity_data] unless entity_data.nil?
          else
            [key, value]
          end
        end
      data.compact.to_h
    end

    def optional_nil_value?(name, value)
      value.nil? && self.class.optional_props.include?(name)
    end

    # Raised, if entity is not valid
    class ValidationError < RuntimeError
    end

    # Raised, if the entity name in the XML is invalid
    class InvalidEntityName < RuntimeError
    end

    # Raised, if the entity contained within the XML cannot be mapped to a
    # defined {Entity} subclass.
    class UnknownEntity < RuntimeError
    end
  end
end
