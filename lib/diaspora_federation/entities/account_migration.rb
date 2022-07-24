# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity is sent when a person changes their diaspora* ID (e.g. when a user migration
    # from one to another pod happens).
    #
    # @see Validators::AccountMigrationValidator
    class AccountMigration < Entity
      include AccountMigration::Signable

      # @!attribute [r] author
      #   Sender of the AccountMigration message. Usually it is the old diaspora* ID of the person who changes their ID.
      #   This property is also allowed to be the new diaspora* ID, which is equal to the author of the included
      #   profile.
      #   @see Person#author
      #   @return [String] author diaspora* ID
      property :author, :string

      # @!attribute [r] profile
      #   Holds new updated profile of a person, including diaspora* ID
      #   @return [Person] person new data
      entity :profile, Entities::Profile

      # @!attribute [r] signature
      #   Signature that validates original and target diaspora* IDs with the private key of the second identity, other
      #   than the entity author. So if the author is the old identity then this signature is made with the new identity
      #   key, and vice versa.
      #   @return [String] signature
      property :signature, :string, default: nil

      # @!attribute [r] old_identity
      #   Optional attribute which keeps old diaspora* ID. Must be present when author attribute contains new diaspora*
      #   ID.
      #   @return [String] old identity
      property :old_identity, :string, default: nil

      # @!attribute [r] remote_photo_path
      #   The url to the path of the photos on the new pod. Can be empty if photos weren't migrated.
      #   @return [String] remote photo path
      property :remote_photo_path, :string, optional: true

      # Returns diaspora* ID of the old person identity.
      # @return [String] diaspora* ID of the old person identity
      def old_identity
        return @old_identity if author_is_new_id?

        author
      end

      # Returns diaspora* ID of the new person identity.
      # @return [String] diaspora* ID of the new person identity
      def new_identity
        profile&.author
      end

      # @return [String] string representation of this object
      alias to_s unique_migration_descriptor

      # Shortcut for calling super method with sensible arguments
      #
      # @see DiasporaFederation::Entities::Signable#verify_signature
      def verify_signature
        super(signer_id, :signature)
      end

      # Calls super and additionally does signature verification for the instantiated entity.
      #
      # @see DiasporaFederation::Entity.from_hash
      def self.from_hash(*args)
        super.tap(&:verify_signature)
      end

      private

      def author_is_new_id?
        author == new_identity
      end

      def signer_id
        author_is_new_id? ? @old_identity : new_identity
      end

      def enriched_properties
        super.tap { |hash| hash[:signature] = signature || sign_with_respective_key }
      end

      # Sign with the key of the #signer_id identity
      # @raise [PrivateKeyNotFound] if the signer's private key is not found
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_respective_key
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, signer_id)
        raise PrivateKeyNotFound, "signer=#{signer_id} obj=#{self}" if privkey.nil?

        sign_with_key(privkey).tap do
          logger.info "event=sign status=complete signature=signature signer=#{signer_id} obj=#{self}"
        end
      end

      # Raised, if creating the signature fails, because the new private key of a user was not found
      class PrivateKeyNotFound < RuntimeError
      end
    end
  end
end
