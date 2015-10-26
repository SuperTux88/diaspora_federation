module DiasporaFederation
  module Salmon
    # +XmlPayload+ provides methods to wrap a XML-serialized {Entity} inside a
    # common XML structure that will become the payload for federation messages.
    #
    # The wrapper looks like so:
    #   <XML>
    #     <post>
    #       {data}
    #     </post>
    #   </XML>
    #
    # (The +post+ element is there for historic reasons...)
    class XmlPayload
      # Encapsulates an Entity inside the wrapping xml structure
      # and returns the XML Object.
      #
      # @param [Entity] entity subject
      # @return [Nokogiri::XML::Element] XML root node
      # @raise [ArgumentError] if the argument is not an Entity subclass
      def self.pack(entity)
        raise ArgumentError, "only instances of DiasporaFederation::Entity allowed" unless entity.is_a?(Entity)

        entity_xml = entity.to_xml
        doc = entity_xml.document
        wrap = Nokogiri::XML::Element.new("XML", doc)
        wrap_post = Nokogiri::XML::Element.new("post", doc)
        entity_xml.parent = wrap_post
        wrap << wrap_post

        wrap
      end

      # Extracts the Entity XML from the wrapping XML structure, parses the entity
      # XML and returns a new instance of the Entity that was packed inside the
      # given payload.
      #
      # @param [Nokogiri::XML::Element] xml payload XML root node
      # @return [Entity] re-constructed Entity instance
      # @raise [ArgumentError] if the argument is not an
      #   {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Element Nokogiri::XML::Element}
      # @raise [InvalidStructure] if the XML doesn't look like the wrapper XML
      # @raise [UnknownEntity] if the class for the entity contained inside the
      #   XML can't be found
      def self.unpack(xml)
        raise ArgumentError, "only Nokogiri::XML::Element allowed" unless xml.instance_of?(Nokogiri::XML::Element)
        raise Salmon::InvalidStructure unless wrap_valid?(xml)

        data = xml.at_xpath("post/*[1]")
        klass_name = entity_class_name(data.name)
        raise Salmon::UnknownEntity, "'#{klass_name}' not found" unless Entities.const_defined?(klass_name)

        klass = Entities.const_get(klass_name)
        populate_entity(klass, data)
      end

      private

      # @param [Nokogiri::XML::Element] element
      def self.wrap_valid?(element)
        (element.name == "XML" && !element.at_xpath("post").nil? &&
         !element.at_xpath("post").children.empty?)
      end
      private_class_method :wrap_valid?

      # Transform the given String from the lowercase underscored version to a
      # camelized variant, used later for getting the Class constant.
      #
      # @param [String] term "snake_case" class name
      # @return [String] "CamelCase" class name
      def self.entity_class_name(term)
        term.to_s.tap do |string|
          raise Salmon::InvalidEntityName, "'#{string}' is invalid" unless string =~ /^[a-z]*(_[a-z]*)*$/
          string.sub!(/^[a-z]/, &:upcase)
          string.gsub!(/_([a-z])/) { Regexp.last_match[1].upcase }
        end
      end
      private_class_method :entity_class_name

      # Construct a new instance of the given Entity and populate the properties
      # with the attributes found in the XML.
      # Works recursively on nested Entities and Arrays thereof.
      #
      # @param [Class] klass entity class
      # @param [Nokogiri::XML::Element] node xml nodes
      # @return [Entity] instance
      def self.populate_entity(klass, node)
        data = {}
        klass.class_props.each do |prop_def|
          name = prop_def[:name]
          type = prop_def[:type]

          if type == String
            data[name] = parse_string_from_node(name, node)
          elsif type.instance_of?(Array)
            data[name] = parse_array_from_node(type, node)
          elsif type.ancestors.include?(Entity)
            data[name] = parse_entity_from_node(type, node)
          end
        end

        klass.new(data)
      end
      private_class_method :populate_entity

      # create simple entry in data hash
      # @return [String] data
      def self.parse_string_from_node(name, node)
        n = node.xpath(name.to_s)
        n.first.text if n.any?
      end
      private_class_method :parse_string_from_node

      # create an entry in the data hash for the nested entity
      # @return [Entity] parsed child entity
      def self.parse_entity_from_node(type, node)
        n = node.xpath(type.entity_name)
        populate_entity(type, n.first) if n.any?
      end
      private_class_method :parse_entity_from_node

      # collect all nested children of that type and create an array in the data hash
      # @return [Array<Entity>] array with parsed child entities
      def self.parse_array_from_node(type, node)
        n = node.xpath(type.first.entity_name)
        n.map {|child| populate_entity(type.first, child) }
      end
      private_class_method :parse_array_from_node
    end
  end
end