# frozen_string_literal: true

module FieldStruct
  class Mutable < Base
    class << self
      def define_setter_meth(name)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}=(value)
            set :#{name}, value
          end
        CODE
      end
    end

    def set(key, value)
      set_by_key key, value, true
    end

    alias []= set

    def valid?
      validate unless validated?
      errors.empty?
    end

    def errors
      @errors ||= []
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

  def self.mutable
    Mutable
  end
end
