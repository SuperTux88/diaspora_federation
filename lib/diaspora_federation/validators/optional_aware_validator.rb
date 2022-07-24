# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # Abstract validator which only validates optional fields when they are not nil.
    class OptionalAwareValidator < Validation::Validator
      def rules
        super.reject do |field, rules|
          @obj.public_send(field).nil? && !rules.map(&:class).include?(Validation::Rule::NotNil) &&
            optional_props.include?(field)
        end
      end

      private

      def optional_props
        return [] unless @obj.class.respond_to?(:optional_props)

        @obj.class.optional_props
      end
    end
  end
end
