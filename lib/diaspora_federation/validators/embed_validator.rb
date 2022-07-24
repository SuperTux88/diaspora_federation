# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Embed}.
    class EmbedValidator < OptionalAwareValidator
      include Validation

      rule :url, :URI
      rule :title, length: { maximum: 255 }
      rule :description, length: { maximum: 65_535 }
      rule :image, URI: %i[host path]
    end
  end
end
