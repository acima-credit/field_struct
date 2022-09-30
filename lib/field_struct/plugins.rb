# frozen_string_literal: true

module FieldStruct
  module Plugins
    @plugins ||= Cache.new

    def self.load_plugin(name)
      h = @plugins
      unless (plugin = h[name])
        require "field_struct/plugins/#{name}"
        unless (plugin = h[name])
          raise Error, "Plugin #{name} did not register itself correctly in FieldStruct::Plugins"
        end
      end
      plugin
    end

    def self.register_plugin(name, mod)
      @plugins[name] = mod
    end
  end
end

require_relative 'plugins/base'
require_relative 'plugins/default_attribute_values'
require_relative 'plugins/aliased_attributes'
require_relative 'plugins/typed_attribute_values'
