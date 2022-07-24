# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Participation}.
    class ParticipationValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id
      rule :guid, :guid
      rule :parent_guid, :guid
      rule :parent_type, [:not_empty, regular_expression: { regex: /\APost\z/ }]
    end
  end
end
