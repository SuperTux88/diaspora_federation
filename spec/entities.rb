# frozen_string_literal: true

module DiasporaFederation
  module Entities
    class TestEntity < DiasporaFederation::Entity
      property :test, :string
    end

    class TestDefaultEntity < DiasporaFederation::Entity
      property :test1, :string
      property :test2, :string
      property :test3, :boolean, default: true
      property :test4, :boolean, default: -> { true }
    end

    class TestOptionalEntity < DiasporaFederation::Entity
      property :test1, :string, optional: true
      property :test2, :string
    end

    class OtherEntity < DiasporaFederation::Entity
      property :asdf, :string
    end

    class TestNestedEntity < DiasporaFederation::Entity
      property :asdf, :string
      entity :test, TestEntity, default: nil
      entity :multi, [OtherEntity]
    end

    class TestEntityWithRelatedEntity < DiasporaFederation::Entity
      property :test, :string
      entity :parent, RelatedEntity
    end

    class Entity < DiasporaFederation::Entity
      property :test, :string
    end

    class TestEntityWithBoolean < DiasporaFederation::Entity
      property :test, :boolean
    end

    class TestEntityWithInteger < DiasporaFederation::Entity
      property :test, :integer
    end

    class TestEntityWithTimestamp < DiasporaFederation::Entity
      property :test, :timestamp
    end

    class TestComplexEntity < DiasporaFederation::Entity
      property :test1, :string
      property :test2, :boolean
      property :test3, :string
      property :test4, :integer
      property :test5, :timestamp
      entity :test6, TestEntity
      property :test7, :string, optional: true
      entity :multi, [OtherEntity], optional: true
    end

    class TestEntityWithAuthorAndGuid < DiasporaFederation::Entity
      property :test, :string
      property :author, :string
      property :guid, :string
    end

    class SomeRelayable < DiasporaFederation::Entity
      PARENT_TYPE = "Parent"

      include Entities::Relayable

      property :property, :string, optional: true
    end

    class TestRelayableWithBoolean < DiasporaFederation::Entity
      PARENT_TYPE = "Parent"

      include Entities::Relayable

      property :test, :boolean
    end
  end

  module Validators
    class TestDefaultEntityValidator < Validation::Validator
      include Validation

      rule :test1, regular_expression: { regex: /\A[^;]{,32}\z/ }
      rule :test2, :not_nil
      rule :test3, :boolean
    end

    class TestEntityWithAuthorAndGuidValidator < Validation::Validator
      include Validation

      rule :test, :boolean
      rule :author, %i[not_empty diaspora_id]
      rule :guid, :guid
    end

    class TestComplexEntityValidator < OptionalAwareValidator
      include Validation

      rule :test1, length: { minimum: 3 }
      rule :test2, :boolean
      rule :test7, length: { minimum: 3 }
      rule :multi, :not_nil
    end

    class TestUnknownEntityValidator < OptionalAwareValidator
      include Validation

      rule :test1, length: { minimum: 3 }
    end
  end
end
