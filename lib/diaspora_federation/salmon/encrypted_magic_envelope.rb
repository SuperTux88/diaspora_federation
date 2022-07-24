# frozen_string_literal: true

module DiasporaFederation
  module Salmon
    # This is a simple crypt-wrapper for {MagicEnvelope}.
    #
    # The wrapper is JSON with the following structure:
    #
    #   {
    #     "aes_key": "...",
    #     "encrypted_magic_envelope": "..."
    #   }
    #
    # +aes_key+ is encrypted using the recipients public key, and contains the AES
    # +key+ and +iv+ as JSON:
    #
    #   {
    #     "key": "...",
    #     "iv": "..."
    #   }
    #
    # +encrypted_magic_envelope+ is encrypted using the +key+ and +iv+ from +aes_key+.
    # Once decrypted it contains the {MagicEnvelope} xml:
    #
    #   <me:env>
    #     ...
    #   </me:env>
    #
    # All JSON-values (+aes_key+, +encrypted_magic_envelope+, +key+ and +iv+) are
    # base64 encoded.
    module EncryptedMagicEnvelope
      # Generates a new random AES key and encrypts the {MagicEnvelope} with it.
      # Then encrypts the AES key with the receivers public key.
      # @param [Nokogiri::XML::Element] magic_env XML root node of a magic envelope
      # @param [OpenSSL::PKey::RSA] pubkey recipient public_key
      # @return [String] json string
      def self.encrypt(magic_env, pubkey)
        key = AES.generate_key_and_iv
        encrypted_env = AES.encrypt(magic_env.to_xml, key[:key], key[:iv])

        encoded_key = key.transform_values { |v| Base64.strict_encode64(v) }
        encrypted_key = Base64.strict_encode64(pubkey.public_encrypt(JSON.generate(encoded_key)))

        JSON.generate(aes_key: encrypted_key, encrypted_magic_envelope: encrypted_env)
      end

      # Decrypts the AES key with the private key of the receiver and decrypts the
      # encrypted {MagicEnvelope} with it.
      # @param [String] encrypted_env json string with aes_key and encrypted_magic_envelope
      # @param [OpenSSL::PKey::RSA] privkey private key for decryption
      # @return [Nokogiri::XML::Element] decrypted magic envelope xml
      def self.decrypt(encrypted_env, privkey)
        encrypted_json = JSON.parse(encrypted_env)

        encoded_key = JSON.parse(privkey.private_decrypt(Base64.decode64(encrypted_json["aes_key"])))
        key = encoded_key.transform_values { |v| Base64.decode64(v) }

        xml = AES.decrypt(encrypted_json["encrypted_magic_envelope"], key["key"], key["iv"])
        Nokogiri::XML(xml).root
      end
    end
  end
end
