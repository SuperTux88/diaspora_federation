# frozen_string_literal: true

module Validation
  module Rule
    # Rule for validating the number of diaspora* IDs in a string.
    # The evaluated string is split at ";".
    class DiasporaIdList
      # This rule can have a +minimum+ or +maximum+ param.
      # @return [Hash] params
      attr_reader :params

      # Creates a new rule for a diaspora* ID list validation
      # @param [Hash] params
      # @option params [Integer] :minimum minimum allowed id count
      # @option params [Integer] :maximum maximum allowed id count
      def initialize(params = {})
        %i[minimum maximum].each do |param|
          if params.include?(param) && !params[param].is_a?(Integer)
            raise ArgumentError, "The :#{param} needs to be an Integer"
          end
        end

        @params = params
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :diaspora_id_list
      end

      def valid_value?(value)
        ids = value.split(";")
        return false if params.include?(:maximum) && ids.count > params[:maximum]
        return false if params.include?(:minimum) && ids.count < params[:minimum]

        ids.each do |id|
          return false if DiasporaId::DIASPORA_ID.match(id).nil?
        end
        true
      end
    end
  end
end
