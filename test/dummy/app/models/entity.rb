# frozen_string_literal: true

class Entity
  attr_accessor :author, :guid
  attr_reader :entity_type

  def initialize(entity_type)
    @entity_type = entity_type
    @guid = UUID.generate(:compact)
  end

  def save!
    Entity.database[entity_type][guid] = self
  end

  class << self
    def find_by(opts)
      database[opts[:entity_type]][opts[:guid]]
    end

    def database
      @database ||= Hash.new {|h, k| h[k] = {} }
    end

    def reset_database
      @database = nil
    end
  end
end
