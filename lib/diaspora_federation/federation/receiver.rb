# frozen_string_literal: true

module DiasporaFederation
  module Federation
    # This module parses and receives entities.
    module Receiver
      extend Logging

      # Receive a public message
      # @param [String] data message to receive
      def self.receive_public(data)
        magic_env_xml = Nokogiri.XML(data).root
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        Public.new(magic_env).receive
      rescue => e # rubocop:disable Style/RescueStandardError
        logger.error "failed to receive public message: #{e.class}: #{e.message}"
        logger.debug "received data:\n#{data}"
        raise e
      end

      # Receive a private message
      # @param [String] data message to receive
      # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
      # @param [Object] recipient_id the identifier to persist the entity for the correct user,
      #   see +receive_entity+ callback
      def self.receive_private(data, recipient_private_key, recipient_id)
        raise ArgumentError, "no recipient key provided" unless recipient_private_key.instance_of?(OpenSSL::PKey::RSA)

        magic_env_xml = Salmon::EncryptedMagicEnvelope.decrypt(data, recipient_private_key)
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        Private.new(magic_env, recipient_id).receive
      rescue => e # rubocop:disable Style/RescueStandardError
        logger.error "failed to receive private message for #{recipient_id}: #{e.class}: #{e.message}"
        logger.debug "received data:\n#{data}"
        raise e
      end
    end
  end
end

require "diaspora_federation/federation/receiver/exceptions"
require "diaspora_federation/federation/receiver/abstract_receiver"
require "diaspora_federation/federation/receiver/public"
require "diaspora_federation/federation/receiver/private"
