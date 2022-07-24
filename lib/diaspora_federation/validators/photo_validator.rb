# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::Photo}.
    class PhotoValidator < OptionalAwareValidator
      include Validation

      rule :guid, :guid

      rule :author, :diaspora_id

      rule :public, :boolean

      rule :remote_photo_path, [:not_empty, URI: [:path]]

      rule :remote_photo_name, :not_empty

      rule :status_message_guid, :guid

      rule :text, length: { maximum: 65_535 }

      rule :height, :numeric

      rule :width, :numeric
    end
  end
end
