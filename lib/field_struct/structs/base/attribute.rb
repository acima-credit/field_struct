# frozen_string_literal: true

module FieldStruct
  class Base
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
        ancestors[1..].find(&:field_struct?)
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

        build_attribute_aliases name, options

        options = Validations.build_for(self, name)

        super name, type, **options
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

        return type if type.is_a?(Symbol) && check_active_model_type(type)
        return type if type.is_a? ::ActiveModel::Type::Value
        return type if type.field_struct?

        raise "Unknown type [#{type.inspect}] (#{type.class.name})"
      end

      def check_active_model_type(type)
        FieldStruct.known_active_model_names.include? type
      end

      def attribute_metadata(name, type, options)
        metadata[name].type = type
        metadata[name].version = type.metadata.version if type.respond_to?(:metadata)
        metadata[name].version = options[:of].metadata.version if options[:of].respond_to?(:metadata)
        metadata.update name, options
      end

      def build_attribute_aliases(old_name, options)
        aliases = Array(options[:alias]).flatten
        aliases.each { |new_name| alias_attribute new_name, old_name }
      end
    end
  end
end
