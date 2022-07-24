# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Discovery::HCard}.
    #
    # @note
    class HCardValidator < OptionalAwareValidator
      include Validation

      rule :guid, :guid

      # The name must not contain a semicolon because of mentions.
      # @{<full_name> ; <diaspora_id>}
      rule :full_name, regular_expression: { regex: /\A[^;]{,70}\z/ }
      rule :first_name, regular_expression: { regex: /\A[^;]{,32}\z/ }
      rule :last_name, regular_expression: { regex: /\A[^;]{,32}\z/ }

      # this urls can be relative
      rule :photo_large_url, [:not_nil, URI: [:path]]
      rule :photo_medium_url, [:not_nil, URI: [:path]]
      rule :photo_small_url, [:not_nil, URI: [:path]]

      rule :public_key, :public_key

      rule :searchable, :boolean
    end
  end
end
