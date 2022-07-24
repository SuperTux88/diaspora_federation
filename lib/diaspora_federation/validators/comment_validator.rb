# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Comment}.
    class CommentValidator < OptionalAwareValidator
      include Validation

      include RelayableValidator

      rule :text, [:not_empty, length: { maximum: 65_535 }]
    end
  end
end
