# frozen_string_literal: true

module DiasporaFederation
  module Federation
    module Receiver
      # Common functionality for receivers
      class AbstractReceiver
        include Logging

        # Creates a new receiver
        # @param [MagicEnvelope] magic_envelope the received magic envelope
        # @param [Object] recipient_id the identifier of the recipient of a private message
        def initialize(magic_envelope, recipient_id = nil)
          @entity = magic_envelope.payload
          @sender = magic_envelope.sender
          @recipient_id = recipient_id
        end

        # Validates and receives the entity
        def receive
          validate_and_receive
        rescue => e # rubocop:disable Style/RescueStandardError
          logger.error "failed to receive #{entity}"
          raise e
        end

        private

        attr_reader :entity, :sender, :recipient_id

        def validate_and_receive
          validate
          fetch_linked_entities_from_text
          DiasporaFederation.callbacks.trigger(:receive_entity, entity, sender, recipient_id)
          logger.info "successfully received #{entity} from person #{sender}#{" for #{recipient_id}" if recipient_id}"
        end

        def validate
          raise InvalidSender, "invalid sender: #{sender}" unless sender_valid?
        end

        def sender_valid?
          entity.respond_to?(:sender_valid?) ? entity.sender_valid?(sender) : sender == entity.author
        end

        def fetch_linked_entities_from_text
          DiasporaUrlParser.fetch_linked_entities(entity.text) if entity.respond_to?(:text) && entity.text
        end
      end
    end
  end
end
