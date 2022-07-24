# frozen_string_literal: true

module DiasporaFederation
  # Logging module for the diaspora* federation
  #
  # It uses the logging-gem if available.
  module Logging
    # Add +logger+ also as class method when included
    # @param [Class] klass the class into which the module is included
    def self.included(klass)
      klass.extend(self)
    end

    private

    # Get the logger for this class
    #
    # Use the logging-gem if available, else use a default logger.
    def logger
      @logger ||=
        if defined?(::Logging::Logger)
          # Use logging-gem if available
          ::Logging::Logger[self]
        elsif defined?(::Rails)
          # Use rails logger if running in rails and no logging-gem is available
          ::Rails.logger
        else
          # fallback logger
          @logger = Logger.new($stdout)
          @logger.level = Logger::INFO
          @logger
        end
    end
  end
end
