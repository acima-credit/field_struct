# frozen_string_literal: true

module FieldStruct
  class Base
    module InstanceMethods
      def initialize(attrs = {})
        super attrs
      end

      def before_attributes_initialize(_attrs)
        # nothing here yet ...
      end

      def after_attributes_initialize(_attrs)
        # nothing here yet ...
      end

      def attr_name(name)
        if self.class.attribute_alias?(name)
          self.class.attribute_alias(name).to_s
        else
          name.to_s
        end
      end

      def get_attribute(name)
        attribute name
      end
      alias [] get_attribute
      alias attr get_attribute

      def assign_attribute(name, value)
        write_attribute name, value
      end
      alias []= assign_attribute
      alias set_attr assign_attribute

      def attribute?(name)
        get_attribute(name).present?
      end
      alias attr? attribute?

      def blank_attribute?(name)
        get_attribute(name).blank?
      end
      alias blank_attr? blank_attribute?

      def nil_attribute?(name)
        get_attribute(name).nil?
      end
      alias nil_attr? nil_attribute?

      def assign_attributes_when_blank(new_attributes)
        _assign_attributes(new_attributes) { |x| blank_attribute? x }
      end

      def assign_attributes_when_nil(new_attributes = {})
        _assign_attributes(new_attributes) { |x| nil_attribute?(x) }
      end

      def assign_attributes(new_attributes)
        _assign_attributes new_attributes
      end

      alias attributes= assign_attributes

      # @param [Hash] options
      # @return [Hash]
      def to_hash(_options = {})
        attributes.each_with_object({}) do |(key, value), hsh|
          hsh[key.to_s] = if value.field_struct?
                            value.to_hash
                          elsif value.is_a?(Array)
                            value.map { |x| x.field_struct? ? x.to_hash : x }
                          else
                            value
                          end
        end
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

      def _assign_attributes(new_attributes)
        unless new_attributes.respond_to?(:stringify_keys)
          raise ArgumentError, 'When assigning attributes, you must pass a hash as an argument.'
        end
        return if new_attributes.empty?

        attributes = new_attributes.stringify_keys
        sanitize_for_mass_assignment(attributes).each do |name, value|
          _assign_attribute(name, value) if !block_given? || yield(name)
        end
      end

      def _assign_attribute(name, value)
        _assign_attribute_with_setter(name, value) ||
          _assign_attribute_directly(name, value) ||
          _assign_attribute_extra(name, value)
      end

      def _assign_attribute_with_setter(name, value)
        setter = :"#{name}="
        return unless respond_to?(setter)

        public_send setter, value
        true
      end

      def _assign_attribute_directly(name_or_alias, value)
        name = attr_name name_or_alias
        return unless @attributes.key?(name)

        @attributes.write_from_user(name, value)
        true
      end

      def _assign_attribute_extra(name, value)
        return true if self.class.extras == :ignore
        raise UnknownAttributeError.new(self, name) if self.class.extras == :raise

        extras[name] = value
        true
      end
    end
  end
end
