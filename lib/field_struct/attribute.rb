# frozen_string_literal: true

module FieldStruct
  class Attribute
    extend Forwardable

    attr_reader :name, :type

    def initialize(name, type, options = {})
      @name = name.to_sym
      @type = type.new options
    end

    def_delegators :@type, :required?, :coercible?, :default?, :default, :coerce, :valid?

    def to_s
      %(#<#{self.class.name} name=#{name.inspect} type=#{type.short_name.inspect} options=#{type.options.inspect}>)
    end

    alias inspect to_s
  end
end
