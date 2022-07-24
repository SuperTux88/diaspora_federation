# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a claim of deletion of a previously federated entity.
    #
    # @see Validators::RetractionValidator
    class Retraction < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person who deletes the entity
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string

      # @!attribute [r] target_guid
      #   Guid of the entity to be deleted
      #   @return [String] target guid
      property :target_guid, :string

      # @!attribute [r] target_type
      #   A string describing the type of the target
      #   @return [String] target type
      property :target_type, :string

      # @!attribute [r] target
      #   Target entity
      #   @return [RelatedEntity] target entity
      entity :target, Entities::RelatedEntity

      def sender_valid?(sender)
        case target_type
        when "Comment", "Like", "PollParticipation"
          [target.root.author, target.author].include?(sender)
        else
          sender == target.author
        end
      end

      # @return [String] string representation of this object
      def to_s
        "Retraction:#{target_type}:#{target_guid}"
      end

      # @see Entity.from_hash
      # @return [Retraction] instance
      def self.from_hash(hash)
        hash[:target] = fetch_target(hash[:target_type], hash[:target_guid])
        new(hash)
      end

      private_class_method def self.fetch_target(target_type, target_guid)
        target = DiasporaFederation.callbacks.trigger(:fetch_related_entity, target_type, target_guid)
        raise TargetNotFound, "not found: #{target_type}:#{target_guid}" unless target

        target
      end

      # Raised, if the target of the {Retraction} was not found.
      class TargetNotFound < RuntimeError
      end
    end
  end
end
