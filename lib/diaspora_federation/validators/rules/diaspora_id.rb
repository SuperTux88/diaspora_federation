# frozen_string_literal: true

module Validation
  module Rule
    # diaspora* ID validation rule
    #
    # A simple rule to validate the base structure of diaspora* IDs.
    class DiasporaId
      # Maximum length of a full diaspora* ID
      DIASPORA_ID_MAX_LENGTH = 255

      # The Regex for a valid diaspora* ID
      DIASPORA_ID_REGEX =
        begin
          username = "[[:lower:]\\d\\-\\.\\_]+"
          hostname_part = "[[:lower:]\\d\\-]"
          hostname = "#{hostname_part}+(?:[.]#{hostname_part}*)*"
          ipv4 = "(?:[\\d]{1,3}\\.){3}[\\d]{1,3}"
          ipv6 = "\\[(?:[[:xdigit:]]{0,4}:){0,7}[[:xdigit:]]{1,4}\\]"
          ip_addr = "(?:#{ipv4}|#{ipv6})"
          domain = "(?:#{hostname}|#{ip_addr})"
          port = "(?::[\\d]+)?"

          "#{username}\\@#{domain}#{port}"
        end

      # The Regex for validating a full diaspora* ID
      DIASPORA_ID = /\A#{DIASPORA_ID_REGEX}\z/u.freeze

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :diaspora_id
      end

      # Determines if value is a valid diaspora* ID
      def valid_value?(value)
        return false unless value.is_a?(String)
        return false if value.length > DIASPORA_ID_MAX_LENGTH

        value =~ DIASPORA_ID
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
