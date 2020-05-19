# frozen_string_literal: true

module FieldStruct
  class Base
    # @param [Class] child
    def self.inherited(child)
      child.send :include, Comparable
      child.send :include, ActiveModel::Model
      child.send :include, ActiveModel::Attributes
      child.send :include, ActiveModel::Validations
      child.send :include, ActiveModel::Serialization
      child.send :include, ActiveModel::Serializers::JSON

      child.send :extend, AttributeMethods
      child.send :extend, ConversionMethods

      child.send :include, InstanceMethods
    end

    module AttributeMethods
      # Initialize an instance
      #
      # @param [Hash] attrs
      def from(attrs = {})
        new attrs
      end

      # Override class name from metadata if available
      #
      # @return [String]
      def name
        @metadata ? @metadata.name : super
      end

      # Get the field struct parent
      #
      # @return [Object, nil]
      def field_ancestor
        ancestors[1..-1].find(&:field_struct?)
      end

      # Keeps information about the columns
      #
      # @return [FieldStruct::Metadata]
      def metadata
        return @metadata if instance_variable_defined?(:@metadata)

        @metadata = Metadata.from self
      end

      # Indicates this class is a FieldStruct class
      #
      # @return [true]
      def field_struct?
        true
      end

      # Add an attribute to the class
      #
      # @param [Symbol] name
      # @param [Symbol, ActiveModel::Type::Value, #field_struct?, String] type
      # @param [Array] args
      # @param [Hash] options
      def attribute(name, type = Type::Value.new, *args, **options)
        arg_options = args.each_with_object({}) { |arg, hsh| hsh[arg.to_sym] = true }
        options = arg_options.merge options

        type = check_allowed_type type
        options[:of] = check_allowed_type(options[:of]) if options.key?(:of)

        attribute_metadata name, type, options

        options = Validations.build_for(self, name)

        super name, type, options
      end

      # Add a required attribute to the class
      #
      # @param [Symbol] name
      # @param [Symbol, ActiveModel::Type::Value, #field_struct?, String] type
      # @param [Array] args
      # @param [Hash] options
      def required(name, type = Type::Value.new, *args, **options)
        attribute name, type, *args.unshift(:required), **options
      end

      # Add an optional attribute to the class
      #
      # @param [Symbol] name
      # @param [Symbol, ActiveModel::Type::Value, #field_struct?, String] type
      # @param [Array] args
      # @param [Hash] options
      def optional(name, type = Type::Value.new, *args, **options)
        attribute name, type, *args.unshift(:optional), **options
      end

      # Allow the class to:
      # :add unknown attributes to the extras hash
      # :ignore unknown attributes
      # :raise an UnknownAttributeError on the first unknown attribute
      #
      # @param [Symbol, nil] value
      # @return [Symbol]
      def extras(value = :no_value)
        @extras = value if %i[add ignore raise].include?(value)
        return @extras if instance_variable_defined?(:@extras)

        return field_ancestor.extras if field_ancestor

        :raise
      end

      private

      # @param [Symbol, ActiveModel::Type::Value, #field_struct?, String] type
      # @return [Symbol, ActiveModel::Type::Value, #field_struct?]
      def check_allowed_type(type)
        type = Kernel.const_get(type) if type.is_a?(String) && Kernel.const_defined?(type)

        return type if type.is_a?(Symbol) && known_basic_types.include?(type)
        return type if type.is_a?(::ActiveModel::Type::Value) || type.field_struct?

        raise "Unknown type [#{type.inspect}] (#{type.class.name})"
      end

      def known_basic_types
        ::ActiveModel::Type.registry.send(:registrations).map { |x| x.send :name }
      end

      def attribute_metadata(name, type, options)
        metadata[name].type = type
        metadata[name].version = type.metadata.version if type.respond_to?(:metadata)
        metadata[name].version = options[:of].metadata.version if options[:of].respond_to?(:metadata)
        metadata.update name, options
      end
    end

    module ConversionMethods
      # @param [Object] value
      # @return [Object]
      def cast(value)
        return value if value.nil?
        return value if value.is_a?(self)
        return new(value) if value.is_a?(Hash)

        raise "invalid value for casting [#{value.class.name}]"
      end

      # @param [Object] value
      # @return [Boolean]
      def assert_valid_value(value)
        value.is_a?(self) || value.is_a?(Hash)
      end

      # @param [String] json
      def from_json(json)
        new JSON.parse(json)
      end
    end

    module InstanceMethods
      def initialize(attrs = {})
        super attrs
      end

      # @param [Hash] options
      # @return [Hash]
      def to_hash(options = {})
        as_json options
      end

      # @param [Object] other
      # @return [Integer]
      def <=>(other)
        to_s <=> other.to_s
      end

      # @return [String]
      def to_s
        attrs_str = attributes.select { |_k, v| v.present? }.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')
        format '#<%s %s>', self.class.name, attrs_str
      end

      alias inspect to_s

      def extras
        @extras ||= {}
      end

      private

      def _assign_attribute(key, value)
        setter = :"#{key}="
        return public_send(setter, value) if respond_to?(setter)
        return _add_extra(key, value) if self.class.extras == :add
        return nil if self.class.extras == :ignore

        raise UnknownAttributeError.new(self, key)
      end

      def _add_extra(key, value)
        extras[key] = value
      end
    end
  end

  def self.types
    @types ||= {}
  end
end
