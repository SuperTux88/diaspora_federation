# frozen_string_literal: true

require "faraday"
require "faraday/follow_redirects"

module DiasporaFederation
  # A wrapper for {https://github.com/lostisland/faraday Faraday}
  #
  # @see Discovery::Discovery
  # @see Federation::Fetcher
  class HttpClient
    # Perform a GET request
    #
    # @param [String] uri the URI
    # @return [Faraday::Response] the response
    def self.get(uri)
      connection.get(uri)
    end

    # Gets the Faraday connection
    #
    # @return [Faraday::Connection] the response
    def self.connection
      create_default_connection unless @connection
      @connection.dup
    end

    private_class_method def self.create_default_connection
      options = {
        request: {
          timeout: DiasporaFederation.http_timeout
        },
        ssl: {
          ca_file: DiasporaFederation.certificate_authorities
        }
      }

      @connection =
        Faraday::Connection.new(options) do |builder|
          builder.use Faraday::FollowRedirects::Middleware, limit: DiasporaFederation.http_redirect_limit

          builder.adapter Faraday.default_adapter
        end

      @connection.headers["User-Agent"] = DiasporaFederation.http_user_agent
    end
  end
end
