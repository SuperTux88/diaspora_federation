# frozen_string_literal: true

module DiasporaFederation
  module Discovery
    # This class implements basic handling of XRD documents as far as it is
    # necessary in the context of the protocols used with diaspora* federation.
    #
    # It also implements handling of the JRD format, see
    # {https://datatracker.ietf.org/doc/html/rfc6415#appendix-A RFC 6415, Appendix A}
    # for a description of the JSON format.
    #
    # @example Creating a XrdDocument
    #   doc = XrdDocument.new
    #   doc.expires = DateTime.new(2020, 1, 15, 0, 0, 1)
    #   doc.subject = "http://example.tld/articles/11"
    #   doc.aliases << "http://example.tld/cool_article"
    #   doc.aliases << "http://example.tld/authors/2/articles/3"
    #   doc.properties["http://x.example.tld/ns/version"] = "1.3"
    #   doc.links << { rel: "author", type: "text/html", href: "http://example.tld/authors/2" }
    #   doc.links << { rel: "copyright", template: "http://example.tld/copyright?id={uri}" }
    #
    #   doc.to_xml
    #
    # @example Parsing a XrdDocument
    #   data = XrdDocument.xml_data(xml_string)
    #
    # @see http://docs.oasis-open.org/xri/xrd/v1.0/xrd-1.0.html Extensible Resource Descriptor (XRD) Version 1.0
    class XrdDocument
      # xml namespace url
      XMLNS = "http://docs.oasis-open.org/ns/xri/xrd-1.0"

      # +Link+ element attributes
      LINK_ATTRS = %i[rel type href template].freeze

      # format string for datetime (+Expires+ element)
      DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

      # The <Expires> element contains a time value which specifies the instant at
      # and after which the document has expired and SHOULD NOT be used.
      # @param [DateTime] value
      attr_writer :expires
      # The <Subject> element contains a URI value which identifies the resource
      # described by this XRD.
      # @param [String] value
      attr_writer :subject

      # @return [Array<String>] list of alias URIs
      attr_reader :aliases

      # @return [Hash<String => mixed>] list of properties. Hash key represents the
      #   +type+ attribute, and the value is the element content
      attr_reader :properties

      # @return [Array<Hash<attr => val>>] list of +Link+ element hashes. Each
      #   hash contains the attributesa and their associated values for the +Link+
      #   element.
      attr_reader :links

      def initialize
        @aliases = []
        @links = []
        @properties = {}
      end

      # Generates an XML document from the current instance and returns it as string
      # @return [String] XML document
      def to_xml
        builder =
          Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml.XRD("xmlns" => XMLNS) do
              xml.Expires(expires.strftime(DATETIME_FORMAT)) if expires.instance_of?(DateTime)

              xml.Subject(subject) if !subject.nil? && !subject.empty?

              add_aliases_to(xml)
              add_properties_to(xml)
              add_links_to(xml)
            end
          end
        builder.to_xml
      end

      def to_json(*_args)
        {
          subject: subject,
          expires: (expires.strftime(DATETIME_FORMAT) if expires.instance_of?(DateTime)),
          aliases: (aliases if aliases.any?),
          properties: (properties if properties.any?),
          links: (links if links.any?)
        }.compact
      end

      # Parse the XRD document from the given string and create a hash containing
      # the extracted data.
      #
      # Small bonus: the hash structure that comes out of this method is the same
      # as the one used to produce a JRD (JSON Resource Descriptor) or parsing it.
      #
      # @param [String] xrd_doc XML string
      # @return [Hash] extracted data
      # @raise [InvalidDocument] if the XRD is malformed
      def self.xml_data(xrd_doc)
        doc = parse_xrd_document(xrd_doc)

        {}.tap do |data|
          exp_elem = doc.at_xpath("xrd:XRD/xrd:Expires", NS)
          data[:expires] = DateTime.strptime(exp_elem.content, DATETIME_FORMAT) unless exp_elem.nil?

          subj_elem = doc.at_xpath("xrd:XRD/xrd:Subject", NS)
          data[:subject] = subj_elem.content unless subj_elem.nil?

          parse_aliases_from_xml_doc(doc, data)
          parse_properties_from_xml_doc(doc, data)
          parse_links_from_xml_doc(doc, data)
        end
      end

      # Parse the JRD document from the given string and create a hash containing
      # the extracted data with symbolized keys.
      #
      # @param [String] jrd_doc JSON string
      # @return [Hash] extracted data
      # @raise [InvalidDocument] if the JRD is malformed
      def self.json_data(jrd_doc)
        json_hash = JSON.parse(jrd_doc)

        {
          subject: json_hash["subject"],
          expires: (DateTime.strptime(json_hash["expires"], DATETIME_FORMAT) if json_hash.key?("expires")),
          aliases: json_hash["aliases"],
          properties: json_hash["properties"],
          links: symbolize_keys_for_links(json_hash["links"])
        }.compact
      rescue JSON::JSONError => e
        raise InvalidDocument,
              "Not a JRD document: #{e.class}: #{e.message[0..255].encode(Encoding.default_external, undef: :replace)}"
      end

      private

      attr_reader :expires, :subject

      NS = { xrd: XMLNS }.freeze

      def add_aliases_to(xml)
        aliases.each do |a|
          next if !a.instance_of?(String) || a.empty?

          xml.Alias(a.to_s)
        end
      end

      def add_properties_to(xml)
        properties.each { |type, val| xml.Property(val.to_s, type: type) }
      end

      def add_links_to(xml)
        links.each do |l|
          attrs = {}
          LINK_ATTRS.each { |attr| attrs[attr.to_s] = l[attr] if l.key?(attr) }
          xml.Link(attrs)
        end
      end

      private_class_method def self.parse_xrd_document(xrd_doc)
        raise ArgumentError unless xrd_doc.instance_of?(String)

        doc = Nokogiri.XML(xrd_doc)
        raise InvalidDocument, "Not an XRD document" if !doc.root || doc.root.name != "XRD"

        doc
      end

      private_class_method def self.parse_aliases_from_xml_doc(doc, data)
        aliases = []
        doc.xpath("xrd:XRD/xrd:Alias", NS).each { |node| aliases << node.content }
        data[:aliases] = aliases unless aliases.empty?
      end

      private_class_method def self.parse_properties_from_xml_doc(doc, data)
        properties = {}
        doc
          .xpath("xrd:XRD/xrd:Property", NS)
          .each { |node| properties[node[:type]] = node.children.empty? ? nil : node.content }
        data[:properties] = properties unless properties.empty?
      end

      # prettier-ignore
      private_class_method def self.parse_links_from_xml_doc(doc, data)
        links = []
        doc
          .xpath("xrd:XRD/xrd:Link", NS)
          .each do |node|
            link = {}
            # prettier-ignore-start
            LINK_ATTRS.each do |attr|
              link[attr] = node[attr.to_s] if node.key?(attr.to_s)
            end
            # prettier-ignore-end
            links << link
          end
        data[:links] = links unless links.empty?
      end

      # symbolize link keys from JSON hash, but only convert known keys
      # prettier-ignore
      private_class_method def self.symbolize_keys_for_links(links)
        # prettier-ignore-start
        links&.map do |link|
          LINK_ATTRS.filter_map { |attr|
            [attr, link[attr.to_s]] if link.key?(attr.to_s)
          }.to_h
        end
        # prettier-ignore-end
      end
    end
  end
end
