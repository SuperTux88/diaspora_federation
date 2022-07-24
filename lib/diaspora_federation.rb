# frozen_string_literal: true

require "nokogiri"
require "openssl"

require "diaspora_federation/version"

require "diaspora_federation/logging"

require "diaspora_federation/callbacks"
require "diaspora_federation/properties_dsl"
require "diaspora_federation/entity"
require "diaspora_federation/validators"

require "diaspora_federation/http_client"

require "diaspora_federation/entities"
require "diaspora_federation/parsers"

require "diaspora_federation/discovery"
require "diaspora_federation/salmon"
require "diaspora_federation/federation"

# diaspora* federation library
module DiasporaFederation
  extend Logging

  @callbacks =
    Callbacks.new %i[
                    fetch_person_for_webfinger
                    fetch_person_for_hcard
                    save_person_after_webfinger
                    fetch_private_key
                    fetch_public_key
                    fetch_related_entity
                    queue_public_receive
                    queue_private_receive
                    receive_entity
                    fetch_public_entity
                    fetch_person_url_to
                    update_pod
                  ]

  # defaults
  @webfinger_http_fallback = false
  @http_concurrency = 20
  @http_timeout = 30
  @http_verbose = false
  @http_redirect_limit = 4
  @http_user_agent = "DiasporaFederation/#{DiasporaFederation::VERSION}"

  class << self
    # {Callbacks} instance with defined callbacks
    # @see Callbacks#on
    # @see Callbacks#trigger
    # @return [Callbacks] callbacks
    attr_reader :callbacks

    # The pod url
    #
    # @overload server_uri
    #   @return [URI] the server uri
    # @overload server_uri=
    #   @example with uri
    #     config.server_uri = URI("http://localhost:3000/")
    #   @example with configured pod_uri
    #     config.server_uri = AppConfig.pod_uri
    #   @param [URI] value the server uri
    attr_accessor :server_uri

    # Set the bundle of certificate authorities (CA) certificates
    #
    # @overload certificate_authorities
    #   @return [String] path to certificate authorities
    # @overload certificate_authorities=
    #   @example
    #     config.certificate_authorities = AppConfig.environment.certificate_authorities.get
    #   @param [String] value path to certificate authorities
    attr_accessor :certificate_authorities

    # Configure if WebFinger discovery should fallback to http if https fails (default: +false+)
    #
    # This is useful for example for development environments where https isn't available.
    #
    # This setting only applies to the WebFinger route from RFC 7033 +/.well-known/webfinger+.
    # Legacy WebFinger flow unconditionally falls back to http.
    #
    # @overload webfinger_http_fallback
    #   @return [Boolean] webfinger http fallback enabled
    # @overload webfinger_http_fallback=
    #   @example
    #     config.webfinger_http_fallback = AppConfig.server.rails_environment == "development"
    #   @param [Boolean] value  webfinger http fallback enabled
    attr_accessor :webfinger_http_fallback

    # Maximum number of parallel HTTP requests made to other pods (default: +20+)
    #
    # @overload http_concurrency
    #   @return [Integer] max number of parallel requests
    # @overload http_concurrency=
    #   @example
    #     config.http_concurrency = AppConfig.settings.typhoeus_concurrency.to_i
    #   @param [Integer] value max number of parallel requests
    attr_accessor :http_concurrency

    # Timeout in seconds for http-requests (default: +30+)
    #
    # @overload http_timeout
    #   @return [Integer] http timeout in seconds
    # @overload http_timeout=
    #   @param [Integer] value http timeout in seconds
    attr_accessor :http_timeout

    # Turn on extra verbose output when sending stuff. (default: +false+)
    #
    # @overload http_verbose
    #   @return [Boolean] verbose http output
    # @overload http_verbose=
    #   @example
    #     config.http_verbose = AppConfig.settings.typhoeus_verbose?
    #   @param [Boolean] value verbose http output
    attr_accessor :http_verbose

    # Max redirects to follow
    # @return [Integer] max redirects
    attr_reader :http_redirect_limit

    # User agent used for http-requests
    # @return [String] user agent
    attr_reader :http_user_agent

    # Configure the federation library
    #
    # @example
    #   DiasporaFederation.configure do |config|
    #     config.server_uri = URI("http://localhost:3000/")
    #
    #     config.define_callbacks do
    #       # callback configuration
    #     end
    #   end
    def configure
      yield self
    end

    # Define the callbacks
    #
    # In order to communicate with the application which uses the diaspora_federation gem
    # callbacks are introduced. The callbacks are used for getting required data from the
    # application or posting data to the application.
    #
    # Callbacks are implemented at the application side and must follow these specifications:
    #
    # fetch_person_for_webfinger
    #   Fetches person data from the application to form a WebFinger reply
    #   @param [String] diaspora* ID of the person
    #   @return [DiasporaFederation::Discovery::WebFinger] person webfinger data
    #
    # fetch_person_for_hcard
    #   Fetches person data from the application to reply for an HCard query
    #   @param [String] guid of the person
    #   @return [DiasporaFederation::Discovery::HCard] person hcard data
    #
    # save_person_after_webfinger
    #   After the gem had made a person discovery using WebFinger it calls this callback
    #   so the application saves the person data
    #   @param [DiasporaFederation::Entities::Person] person data
    #
    # fetch_private_key
    #   Fetches a private key of a person by her diaspora* ID from the application
    #   @param [String] diaspora* ID of the person
    #   @return [OpenSSL::PKey::RSA] key
    #
    # fetch_public_key
    #   Fetches a public key of a person by her diaspora* ID from the application
    #   @param [String] diaspora* ID of the person
    #   @return [OpenSSL::PKey::RSA] key
    #
    # fetch_related_entity
    #   Fetches a related entity by a given guid
    #   @param [String] entity_type (Post, Comment, Like, etc)
    #   @param [String] guid of the entity
    #   @return [DiasporaFederation::Entities::RelatedEntity] related entity
    #
    # queue_public_receive
    #   Queue a public salmon xml to process in background
    #   @param [String] data salmon slap xml or magic envelope xml
    #
    # queue_private_receive
    #   Queue a private salmon xml to process in background
    #   @param [String] guid guid of the receiver person
    #   @param [String] data salmon slap xml or encrypted magic envelope json
    #   @return [Boolean] true if successful, false if the user was not found
    #
    # receive_entity
    #   After the xml was parsed and processed the gem calls this callback to persist the entity
    #   @param [DiasporaFederation::Entity] entity the received entity after processing
    #   @param [Object] recipient_id identifier for the recipient of private messages or nil for public,
    #     see {Receiver.receive_private}
    #
    # fetch_public_entity
    #   Fetch a public entity from the database
    #   @param [String] entity_type (Post, StatusMessage, etc)
    #   @param [String] guid the guid of the entity
    #
    # fetch_person_url_to
    #   Fetch the url to path for a person
    #   @param [String] diaspora_id
    #   @param [String] path
    #
    # update_pod
    #   Update the pod status
    #   @param [String] url the pod url
    #   @param [Symbol, Integer] status the error as {Symbol} or the http-status as {Integer} if it was :ok
    #
    # @see Callbacks#on
    #
    # @example
    #   config.define_callbacks do
    #     on :some_event do |arg1|
    #       # do something
    #     end
    #   end
    #
    # @param [Proc] block the callbacks to define
    def define_callbacks(&block)
      @callbacks.instance_eval(&block)
    end

    # Validates if the engine is configured correctly
    #
    # called from after_initialize
    # @raise [ConfigurationError] if the configuration is incomplete or invalid
    def validate_config
      configuration_error "server_uri: Missing or invalid" unless @server_uri.respond_to? :host

      unless defined?(::Rails) && !::Rails.env.production?
        configuration_error "certificate_authorities: Not configured" if @certificate_authorities.nil?
        unless File.file? @certificate_authorities
          configuration_error "certificate_authorities: File not found: #{@certificate_authorities}"
        end
      end

      validate_http_config

      unless @callbacks.definition_complete?
        configuration_error "Missing handlers for #{@callbacks.missing_handlers.join(", ")}"
      end

      logger.info "successfully configured the federation library"
    end

    private

    def validate_http_config
      configuration_error "http_concurrency: please configure a number" unless @http_concurrency.is_a?(Integer)
      configuration_error "http_timeout: please configure a number" unless @http_timeout.is_a?(Integer)

      return unless !@http_verbose.is_a?(TrueClass) && !@http_verbose.is_a?(FalseClass)

      configuration_error "http_verbose: please configure a boolean"
    end

    def configuration_error(message)
      logger.fatal "diaspora federation configuration error: #{message}"
      raise ConfigurationError, message
    end
  end

  # Raised, if the engine is not configured correctly
  class ConfigurationError < RuntimeError
  end
end
