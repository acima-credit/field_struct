# frozen_string_literal: true

class FieldStruct
  class Mutable < Base
    def set(key, value)
      set_by_key key, value
    end

    alias []= set

    def valid?
      validate unless validated?
      errors.empty?
    end

    def errors
      @errors ||= []
    end

    def method_missing(meth, *args, &block)
      attr_name = attr_writer?(meth)
      return super unless attr_name

      set_by_key(attr_name, args.first).tap { @validated = false }
    end

    def respond_to_missing?(meth, priv = false)
      attr_writer?(meth) ? true : super
    end

    private

    def attr_writer?(name)
      match = name.match(/^([\w_]*)=$/i)
      return false unless match

      self.class.attributes.key?(match[1].to_sym) ? match[1] : false
    end

    def validated?
      @validated
    end

    def validate
      @errors    = []
      @validated = false
      super
      @validated = true
      valid?
    end

    def validate_attribute(attr)
      check = attr.valid? get(attr.name)
      return check if check.valid?

      errors << format(':%s %s', attr.name, check.errors.first)
      check
    end
  end
end
