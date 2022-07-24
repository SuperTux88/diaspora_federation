# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This is a module that defines common properties for relayable entities
    # which include Like, Comment, Participation, Message, etc. Each relayable
    # has a parent, identified by guid. Relayables are also signed and signing/verification
    # logic is embedded into Salmon XML processing code.
    module Relayable
      include Signable

      # Additional properties from parsed input object
      # @return [Hash] additional elements
      attr_reader :additional_data

      # On inclusion of this module the required properties for a relayable are added to the object that includes it.
      #
      # @!attribute [r] author
      #   The diaspora* ID of the author
      #   @see Person#author
      #   @return [String] diaspora* ID
      #
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] comment guid
      #
      # @!attribute [r] parent_guid
      #   @see StatusMessage#guid
      #   @return [String] parent guid
      #
      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a relayable itself.
      #   The presence of this signature is mandatory. Without it the entity won't be accepted by
      #   a target pod.
      #   @return [String] author signature
      #
      # @!attribute [r] parent
      #   Meta information about the parent object
      #   @return [RelatedEntity] parent entity
      #
      # @param [Entity] klass the entity in which it is included
      def self.included(klass)
        klass.class_eval do
          property :author, :string
          property :guid, :string
          property :parent_guid, :string
          property :author_signature, :string, default: nil
          entity :parent, Entities::RelatedEntity
        end

        klass.extend Parsing
      end

      # Initializes a new relayable Entity with order and additional xml elements
      #
      # @param [Hash] data entity data
      # @param [Array] signature_order order for the signature
      # @param [Hash] additional_data additional xml elements
      # @see DiasporaFederation::Entity#initialize
      def initialize(data, signature_order=nil, additional_data={})
        self.signature_order = signature_order if signature_order
        self.additional_data = additional_data

        super(data)
      end

      # Verifies the +author_signature+ if needed.
      # @see DiasporaFederation::Entities::Signable#verify_signature
      #
      # @raise [SignatureVerificationFailed] if the signature is not valid
      # @raise [PublicKeyNotFound] if no public key is found
      def verify_signature
        super(author, :author_signature) unless author == parent.root.author
      end

      def sender_valid?(sender)
        (sender == author && parent.root.local) || sender == parent.root.author
      end

      # @return [String] string representation of this object
      def to_s
        "#{super}#{":#{parent_type}" if respond_to?(:parent_type)}:#{parent_guid}"
      end

      def to_json(*_args)
        super.merge!(property_order: signature_order).tap { |json_hash|
          missing_properties = json_hash[:property_order] - json_hash[:entity_data].keys
          missing_properties.each { |property|
            json_hash[:entity_data][property] = nil
          }
        }
      end

      # The order for signing
      # @return [Array]
      def signature_order
        @signature_order || (self.class.class_props.keys.reject { |key|
          self.class.optional_props.include?(key) && public_send(key).nil?
        } - %i[author_signature parent])
      end

      private

      # Sign with author key
      # @raise [AuthorPrivateKeyNotFound] if the author private key is not found
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_author
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, author)
        raise AuthorPrivateKeyNotFound, "author=#{author} obj=#{self}" if privkey.nil?

        sign_with_key(privkey).tap do
          logger.info "event=sign status=complete signature=author_signature author=#{author} obj=#{self}"
        end
      end

      # Update the signatures with the keys of the author and the parent
      # if the signatures are not there yet and if the keys are available.
      #
      # @return [Hash] properties with updated signatures
      def enriched_properties
        super.merge(additional_data).tap do |hash|
          hash[:author_signature] = author_signature || sign_with_author unless author == parent.root.author
        end
      end

      # Sort all XML elements according to the order used for the signatures.
      #
      # @return [Hash] sorted xml elements
      def xml_elements
        data = super
        order = signature_order
        order += %i[author_signature] unless author == parent.root.author
        order.to_h { |element| [element, data[element].to_s] }
      end

      def signature_order=(order)
        prop_names = self.class.class_props.keys.map(&:to_s)
        @signature_order = order.grep_v(/signature/)
                                .map { |name| prop_names.include?(name) ? name.to_sym : name }
      end

      def additional_data=(additional_data)
        @additional_data = additional_data.reject { |name, _| name =~ /signature/ }
      end

      # @return [String] signature data string
      def signature_data
        data = normalized_properties.merge(additional_data)
        signature_order.map { |name| data[name] }.join(";")
      end

      # Override class methods from {Entity} to parse serialized data
      module Parsing
        # Does the same job as Entity.from_hash except of the following differences:
        # 1) unknown properties from the properties_hash are stored to additional_data of the relayable instance
        # 2) parent entity fetch is attempted
        # 3) signatures verification is performed; property_order is used as the order in which properties are composed
        # to compute signatures
        # 4) unknown properties' keys must be of String type
        #
        # @see Entity.from_hash
        def from_hash(properties_hash, property_order)
          # Use all known properties to build the Entity (entity_data). All additional elements
          # are respected and attached to a hash as string (additional_data). This is needed
          # to support receiving objects from the future versions of diaspora*, where new elements may have been added.
          additional_data = properties_hash.reject { |key, _| class_props.has_key?(key) }

          fetch_parent(properties_hash)
          new(properties_hash, property_order, additional_data).tap(&:verify_signature)
        end

        private

        def fetch_parent(data)
          type = data.fetch(:parent_type) {
            break self::PARENT_TYPE if const_defined?(:PARENT_TYPE)

            raise DiasporaFederation::Entity::ValidationError, error_message_missing_property(data, "parent_type")
          }
          guid = data.fetch(:parent_guid) {
            raise DiasporaFederation::Entity::ValidationError, error_message_missing_property(data, "parent_guid")
          }

          data[:parent] = RelatedEntity.fetch(data[:author], type, guid)
        end

        def error_message_missing_property(data, missing_property)
          obj_str = "#{class_name}#{":#{data[:guid]}" if data.has_key?(:guid)}" \
                    "#{" from #{data[:author]}" if data.has_key?(:author)}"
          "Invalid #{obj_str}! Missing '#{missing_property}'."
        end

        def xml_parser_class
          DiasporaFederation::Parsers::RelayableXmlParser
        end

        def json_parser_class
          DiasporaFederation::Parsers::RelayableJsonParser
        end
      end

      # Raised, if creating the author_signature fails, because the private key was not found
      class AuthorPrivateKeyNotFound < RuntimeError
      end
    end
  end
end
