# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Event}.
    class EventValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id

      rule :guid, :guid

      rule :summary, [:not_empty, length: { maximum: 255 }]
      rule :description, length: { maximum: 65_535 }

      rule :start, :not_nil

      rule :all_day, :boolean

      rule :timezone, regular_expression: { regex: %r{\A[A-Za-z_-]{,14}(/[A-Za-z_-]{,14}){1,2}\z} }
    end
  end
end
