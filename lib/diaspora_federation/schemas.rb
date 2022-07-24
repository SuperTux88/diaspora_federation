# frozen_string_literal: true

require "pathname"
require "json"

module DiasporaFederation
  # A helper class to access the JSON schema.
  module Schemas
    # federation_entities schema uri
    FEDERATION_ENTITIES_URI = "https://diaspora.github.io/diaspora_federation/schemas/federation_entities.json"

    # Parsed federation_entities schema
    def self.federation_entities
      @federation_entities ||= JSON.parse(Pathname.new(__dir__).join("schemas", "federation_entities.json").read)
    end
  end
end
