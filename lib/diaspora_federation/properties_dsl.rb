# frozen_string_literal: true

module DiasporaFederation
  # Provides a simple DSL for specifying {Entity} properties during class
  # definition.
  #
  # @example
  #   property :prop
  #   property :optional, default: false
  #   property :dynamic_default, default: -> { Time.now }
  #   property :original_prop, alias: :alias_prop
  #   entity :nested, NestedEntity
  #   entity :multiple, [OtherEntity]
  module PropertiesDSL
    # @return [Hash] hash of declared entity properties
    def class_props
      @class_props ||= {}
    end

    # Define a generic (string-type) property
    # @param [Symbol] name property name
    # @param [Symbol] type property type
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def property(name, type, opts={})
      raise InvalidType unless property_type_valid?(type)

      define_property name, type, opts
    end

    # Define a property that should contain another Entity or an array of
    # other Entities
    # @param [Symbol] name property name
    # @param [Entity, Array<Entity>] type Entity subclass or
    #                Array with exactly one Entity subclass constant inside
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def entity(name, type, opts={})
      raise InvalidType unless entity_type_valid?(type)

      define_property name, type, opts
    end

    # Return array of missing required property names
    # @return [Array<Symbol>] missing required property names
    def missing_props(args)
      class_props.keys - default_props.keys - optional_props - args.keys
    end

    def optional_props
      @optional_props ||= []
    end

    # Return a new hash of default values, with dynamic values
    # resolved on each call
    # @return [Hash] default values
    def default_values
      optional_props.to_h { |name| [name, nil] }.merge(default_props).transform_values { |prop|
        prop.respond_to?(:call) ? prop.call : prop
      }
    end

    # @param [Hash] data entity data
    # @return [Hash] hash with resolved aliases
    def resolv_aliases(data)
      data.to_h { |name, value|
        if class_prop_aliases.has_key? name
          prop_name = class_prop_aliases[name]
          raise InvalidData, "only use '#{name}' OR '#{prop_name}'" if data.has_key? prop_name

          [prop_name, value]
        else
          [name, value]
        end
      }
    end

    private

    def define_property(name, type, opts={})
      raise InvalidName unless name_valid?(name)

      class_props[name] = type
      optional_props << name if opts[:optional]
      default_props[name] = opts[:default] if opts.has_key? :default

      instance_eval { attr_reader name }

      define_alias(name, opts[:alias]) if opts.has_key? :alias
    end

    # Checks if the name is a +Symbol+ or a +String+
    # @param [String, Symbol] name the name to check
    # @return [Boolean]
    def name_valid?(name)
      name.instance_of?(Symbol)
    end

    def property_type_valid?(type)
      %i[string integer boolean timestamp].include?(type)
    end

    # Checks if the type extends {Entity}
    # @param [Class] type the type to check
    # @return [Boolean]
    def entity_type_valid?(type)
      [type].flatten.all? { |type|
        type.respond_to?(:ancestors) && type.ancestors.include?(Entity)
      }
    end

    def default_props
      @default_props ||= {}
    end

    # Returns all alias mappings
    # @return [Hash] alias properties
    def class_prop_aliases
      @class_prop_aliases ||= {}
    end

    # @param [Symbol] name property name
    # @param [Symbol] alias_name alias name
    def define_alias(name, alias_name)
      class_prop_aliases[alias_name] = name
      instance_eval { alias_method alias_name, name }
    end

    # Raised, if the name is of an unexpected type
    class InvalidName < RuntimeError
    end

    # Raised, if the type is of an unexpected type
    class InvalidType < RuntimeError
    end

    # Raised, if the data contains property twice (with name AND alias)
    class InvalidData < RuntimeError
    end
  end
end
