# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::PollAnswer}.
    class PollAnswerValidator < OptionalAwareValidator
      include Validation

      rule :guid, :guid
      rule :answer, [:not_empty, length: { maximum: 255 }]
    end
  end
end
