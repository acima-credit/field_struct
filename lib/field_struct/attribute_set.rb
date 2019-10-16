# frozen_string_literal: true

module FieldStruct
  class AttributeSet
    extend Forwardable

    def initialize(klass)
      @all = build_ancestor_attributes klass
    end

    def_delegators :@all, :[], :values, :key?, :key?, :to_hash
    def_delegator :@all, :keys, :names
    def_delegators :values, :select, :each, :each_with_object, :find

    def add(name, type, *args)
      @all[name] ||= Attribute.new name, find_type(type), parse_options(*args)
    end

    private

    def build_ancestor_attributes(klass)
      found = false
      klass.ancestors[1..-1].reverse.each_with_object({}) do |ancestor, hsh|
        hsh.update(ancestor.attributes.to_hash) if found
        found = true if ancestor == FieldStruct::Base
      end
    end

    def find_type(type)
      return type if type.is_a?(Types::Type)

      if type.is_a? Symbol
        found = Types.registry.find { |x| x.short_name == type.to_s }
        return found unless found.nil?
      end

      raise TypeError, "Unknown type [#{type.inspect}]"
    end

    def parse_options(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |arg|
        case arg
        when :coercible
          options[:coercible] = true
        when :strict
          options[:coercible] = false
        when :required
          options[:required] = true
        when :optional
          options[:required] = false
        else
          raise AttributeOptionError, "Unknown option for attribute [#{arg.inspect}]"
        end
      end
      options
    end
  end
end
