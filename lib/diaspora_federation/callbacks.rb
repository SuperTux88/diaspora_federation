# frozen_string_literal: true

module DiasporaFederation
  # Callbacks are used to communicate with the application. They are called to
  # fetch data and after data is received.
  class Callbacks
    # Initializes a new Callbacks object with the event-keys that need to be defined
    #
    # @example
    #   Callbacks.new %i(
    #     some_event
    #     another_event
    #   )
    #
    # @param [Hash] events event keys
    def initialize(events)
      @events = events
      @handlers = {}
    end

    # Defines a callback
    #
    # @example
    #   callbacks.on :some_event do |arg1|
    #     # do something
    #   end
    #
    # @param [Symbol] event the event key
    # @param [Proc] callback the callback block
    # @raise [ArgumentError] if the event key is undefined or has already a handler
    def on(event, &callback)
      raise ArgumentError, "Undefined event #{event}" unless @events.include? event
      raise ArgumentError, "Already defined event #{event}" if @handlers.has_key? event

      @handlers[event] = callback
    end

    # Triggers a callback
    #
    # @example
    #   callbacks.trigger :some_event, "foo"
    #
    # @param [Symbol] event the event key
    # @return [Object] the return-value of the callback
    # @raise [ArgumentError] if the event key is undefined
    def trigger(event, *args)
      raise ArgumentError, "Undefined event #{event}" unless @events.include? event

      @handlers[event].call(*args)
    end

    # Checks if all callbacks are defined
    # @return [Boolean]
    def definition_complete?
      missing_handlers.empty?
    end

    # Returns all undefined callbacks
    # @return [Hash] callback keys
    def missing_handlers
      @events - @handlers.keys
    end
  end
end
