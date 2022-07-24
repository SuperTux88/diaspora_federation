# frozen_string_literal: true

module DiasporaFederation
  module Federation
    # Federation logic to send messages to other pods
    module Sender
      # Send a public message to all urls
      #
      # @param [String] sender_id sender diaspora-ID
      # @param [String] obj_str object string representation for logging (e.g. type@guid)
      # @param [Array<String>] urls receive-urls from pods
      # @param [String] xml salmon-xml
      # @return [Array<String>] url to retry
      def self.public(sender_id, obj_str, urls, xml)
        hydra = HydraWrapper.new(sender_id, obj_str)
        urls.each { |url| hydra.insert_magic_env_request(url, xml) }
        hydra.send
      end

      # Send a private message to receive-urls
      #
      # @param [String] sender_id sender diaspora-ID
      # @param [String] obj_str object string representation for logging (e.g. type@guid)
      # @param [Hash] targets Hash with receive-urls (key) of peoples with encrypted salmon-xml for them (value)
      # @return [Hash] targets to retry
      def self.private(sender_id, obj_str, targets)
        hydra = HydraWrapper.new(sender_id, obj_str)
        targets.each { |url, json| hydra.insert_enc_magic_env_request(url, json) }
        hydra.send.to_h { |url| [url, targets[url]] }
      end
    end
  end
end

require "diaspora_federation/federation/sender/hydra_wrapper"
