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
      child.send :extend, TypeValidationMethods
      child.send :include, InstanceMethods
    end

    module AttributeMethods
      # Keeps information about the columns
      #
      # @return [Hash]
      def metadata
        @metadata ||= {}
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
      # @param [Symbol, Type::Value, FieldStruct::Base] type
      # @param [Array] args
      # @param [Hash] options
      def attribute(name, type = Type::Value.new, *args, **options)
        arg_options = args.each_with_object({}) { |arg, hsh| hsh[arg.to_sym] = true }
        metadata[name] = { type: type }
        options = arg_options.merge(options)
        options = add_validations name, type, options

        super name, type, options
      end

      # Add a required attribute to the class
      #
      # @param [Symbol] name
      # @param [Symbol, Type::Value, FieldStruct::Base] type
      # @param [Array] args
      # @param [Hash] options
      def required(name, type = Type::Value.new, *args, **options)
        attribute name, type, *args.unshift(:required), **options
      end

      # Add an optional attribute to the class
      #
      # @param [Symbol] name
      # @param [Symbol, Type::Value, FieldStruct::Base] type
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

        ancestor = ancestors[1..-1].find { |x| x.respond_to? :extras }
        return ancestor.extras if ancestor

        :raise
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

    module TypeValidationMethods
      private

      # @param [Symbol] name
      # @param [Symbol, Type::Value, FieldStruct::Base] type
      # @param [Hash] options
      def add_validations(name, type, options)
        add_field_struct_validation name, type
        add_required_validation name, options
        add_format_validation name, options
        add_enum_validation name, options
        add_length_in_validation name, options
        add_length_min_validation name, options
        add_length_max_validation name, options

        options
      end

      # @param [Symbol] name
      # @param [Symbol, Type::Value, FieldStruct::Base] type
      def add_field_struct_validation(name, type)
        return unless type.respond_to?(:field_struct?) && type.field_struct?

        validates_each name, allow_nil: true do |record, attr, _value|
          nested_attr = record.send(attr)
          unless nested_attr.valid?
            nested_attr.errors.to_hash.each do |field, labels|
              labels.each { |label| record.errors.add attr, "#{field} #{label}" }
            end
          end
        end
      end

      def add_required_validation(name, options)
        optional = options.delete(:optional).to_s
        required = options.delete(:required).to_s
        return unless required == 'true' || optional == 'false'

        validates_presence_of name
        metadata[name][:required] = true
      end

      def add_format_validation(name, options)
        format = options.delete :format
        return unless format

        validates_format_of name, allow_nil: true, with: format
        metadata[name][:format] = format
      end

      def add_enum_validation(name, options)
        enum = options.delete :enum
        return unless enum

        validates_inclusion_of name, allow_nil: true, in: enum
        metadata[name][:enum] = enum
      end

      def add_length_in_validation(name, options)
        length = options.delete :length
        return unless length

        validates_length_of name, allow_nil: true, in: length
        metadata[name][:in] = enum
      end

      def add_length_min_validation(name, options)
        min_length = options.delete :min_length
        return unless min_length

        validates_length_of name, allow_nil: true, minimum: min_length
        metadata[name][:min] = min_length
      end

      def add_length_max_validation(name, options)
        max_length = options.delete :max_length
        return unless max_length

        validates_length_of name, allow_nil: true, maximum: max_length
        metadata[name][:max] = max_length
      end
    end

    module InstanceMethods
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
end
