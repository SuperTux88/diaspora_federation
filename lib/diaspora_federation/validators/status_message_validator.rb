# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::StatusMessage}.
    class StatusMessageValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id

      rule :guid, :guid

      rule :text, length: { maximum: 65_535 }

      rule :photos, :not_nil

      rule :public, :boolean
    end
  end
end
