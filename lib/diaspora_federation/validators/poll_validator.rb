# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Poll}.
    class PollValidator < OptionalAwareValidator
      include Validation

      rule :guid, :guid
      rule :question, [:not_empty, length: { maximum: 255 }]
      rule :poll_answers, length: { minimum: 2 }
    end
  end
end
