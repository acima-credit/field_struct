# frozen_string_literal: true

require_relative 'plugins/'

module FieldStruct
  module Types
    @types ||= Cache.new

    # @param [Symbol] name
    def self.load_plugin(name)
      h = @types
      unless (type = h[name])
        require "field_struct/types/#{name}"
        unless (type = h[name])
          raise Error, "Plugin #{name} did not register itself correctly in FieldStruct::Plugins"
        end
      end
      type
    end

    # @param [Class<FieldStruct::Types::Base>] mod
    def self.register_type(mod)
      raise "invalid type [#{mod}]" unless mod.respond_to?(:type)

      @types[mod.type] = mod
    end

    def self.get(name)
      @types[name]
    end
  end
end

require_relative 'types/base'
require_relative 'types/boolean'
require_relative 'types/date'
require_relative 'types/date_time'
require_relative 'types/integer'
require_relative 'types/string'
