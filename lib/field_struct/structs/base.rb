# frozen_string_literal: true

module FieldStruct
  class Base
    class << self
      def attributes
        @attributes ||= AttributeSet.new
      end

      def attribute(name, type, *args)
        attributes.add name, type, *args
      end

      def required(name, type, *args)
        args.unshift :required
        attribute name, type, *args
      end

      def optional(name, type, *args)
        args.unshift :optional
        attribute name, type, *args
      end

      def attribute_names
        attributes.names
      end

      def default_attributes
        attributes
          .select(&:default?)
          .each_with_object({}) { |x, h| h[x.name] = x.default }
      end

      def new(*args)
        super
      rescue StandardError => e
        exc = BuildError.new(e.message).tap { |x| x.set_backtrace e.backtrace }
        raise exc
      end
    end

    include Comparable

    def initialize(*args)
      attrs = args.last.is_a?(Hash) ? args.pop : {}
      @attributes ||= {}
      assign_attrs_by_index args
      assign_attrs_by_key attrs
      assign_defaults
      validate
    end

    def get(key)
      @attributes[key.to_sym]
    end

    alias [] get

    def values
      self.class.attribute_names.map { |name| send name }
    end

    def to_hash
      self.class.attribute_names.each_with_object({}) { |x, h| h[x] = get x }
    end

    alias to_h to_hash

    def method_missing(meth, *args, &block)
      attr?(meth) ? get(meth) : super
    end

    def respond_to_missing?(meth, priv = false)
      attr?(meth) ? true : super
    end

    def to_s
      "#<#{self.class.name} #{to_hash.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
    end

    alias inspect to_s

    private

    def assign_attrs_by_index(args)
      args.each_with_index { |value, idx| set_by_index idx, value }
    end

    def assign_attrs_by_key(attrs)
      attrs.each { |key, value| set_by_key key, value }
    end

    def assign_defaults
      self.class.default_attributes.each { |k, v| set_if_missing k, v }
    end

    def validate
      self.class.attributes.each do |attr|
        check = validate_attribute attr
        set_by_key attr.name, check.value
      end
    end

    def attr?(name)
      self.class.attributes.key? name.to_sym
    end

    def set_by_key(key, value, invalidate = false)
      @attributes[key.to_sym] = value
      @validated = false if invalidate
    end

    def set_by_index(idx, value)
      key = self.class.attribute_names[idx]
      set_by_key key, value
    end

    def set_if_missing(key, value)
      return if @attributes.key? key.to_sym

      set_by_key key, value
    end
  end
end
