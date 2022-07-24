# frozen_string_literal: true

module DiasporaFederation
  module Salmon
    # Class for AES encryption and decryption
    class AES
      # OpenSSL aes cipher definition
      CIPHER = "AES-256-CBC"

      # Generates a random AES key and initialization vector
      # @return [Hash] { key: "...", iv: "..." }
      def self.generate_key_and_iv
        cipher = OpenSSL::Cipher.new(CIPHER)
        { key: cipher.random_key, iv: cipher.random_iv }
      end

      # Encrypts the given data with an AES cipher defined by the given key
      # and iv and returns the resulting ciphertext base64 strict_encoded.
      # @param [String] data plain input
      # @param [String] key AES key
      # @param [String] iv AES initialization vector
      # @return [String] base64 encoded ciphertext
      # @raise [ArgumentError] if any of the arguments is missing or not the correct type
      def self.encrypt(data, key, iv) # rubocop:disable Naming/MethodParameterName
        raise ArgumentError unless data.instance_of?(String) &&
                                   key.instance_of?(String) &&
                                   iv.instance_of?(String)

        cipher = OpenSSL::Cipher.new(CIPHER)
        cipher.encrypt
        cipher.key = key
        cipher.iv = iv

        ciphertext = cipher.update(data) + cipher.final

        Base64.strict_encode64(ciphertext)
      end

      # Decrypts the given ciphertext with an AES cipher defined by the given key
      # and iv. +ciphertext+ is expected to be base64 encoded
      # @param [String] ciphertext input data
      # @param [String] key AES key
      # @param [String] iv AES initialization vector
      # @return [String] decrypted plain message
      # @raise [ArgumentError] if any of the arguments is missing or not the correct type
      def self.decrypt(ciphertext, key, iv) # rubocop:disable Naming/MethodParameterName
        raise ArgumentError unless ciphertext.instance_of?(String) &&
                                   key.instance_of?(String) &&
                                   iv.instance_of?(String)

        decipher = OpenSSL::Cipher.new(CIPHER)
        decipher.decrypt
        decipher.key = key
        decipher.iv = iv

        decipher.update(Base64.decode64(ciphertext)) + decipher.final
      end
    end
  end
end
