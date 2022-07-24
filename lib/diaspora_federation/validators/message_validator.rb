# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Message}.
    class MessageValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id
      rule :guid, :guid
      rule :conversation_guid, :guid

      rule :text, [:not_empty,
                   length: { maximum: 65_535 }]
    end
  end
end
