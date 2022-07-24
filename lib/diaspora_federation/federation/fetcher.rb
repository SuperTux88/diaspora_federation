# frozen_string_literal: true

module DiasporaFederation
  module Federation
    # This module is for fetching entities from other pods.
    module Fetcher
      # Fetches a public entity from a remote pod
      # @param [String] author the diaspora* ID of the author of the entity
      # @param [Symbol, String] entity_type snake_case version of the entity class
      # @param [String] guid guid of the entity to fetch
      # @raise [NotFetchable] if something with the fetching failed
      def self.fetch_public(author, entity_type, guid)
        type = entity_name(entity_type).to_s
        raise "Already fetching ..." if fetching[type].include?(guid)

        fetch_from_url(author, type, guid)
      rescue => e # rubocop:disable Style/RescueStandardError
        raise NotFetchable, "Failed to fetch #{entity_type}:#{guid} from #{author}: #{e.class}: #{e.message}"
      end

      private_class_method def self.entity_name(class_name)
        return class_name if class_name =~ /\A#{Entity::ENTITY_NAME_REGEX}\z/

        raise DiasporaFederation::Entity::UnknownEntity, class_name unless Entities.const_defined?(class_name)

        class_name.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end

      private_class_method def self.fetch_from_url(author, type, guid)
        fetching[type] << guid

        url = DiasporaFederation.callbacks.trigger(:fetch_person_url_to, author, "/fetch/#{type}/#{guid}")
        response = HttpClient.get(url)
        raise "Failed to fetch #{url}: #{response.status}" unless response.success?

        Receiver.receive_public(response.body)
      ensure
        fetching[type].delete(guid)
      end

      # currently fetching entities in the same thread
      private_class_method def self.fetching
        Thread.current[:fetching_entities] ||= Hash.new { |h, k| h[k] = [] }
      end

      # Raised, if the entity is not fetchable
      class NotFetchable < RuntimeError
      end
    end
  end
end
