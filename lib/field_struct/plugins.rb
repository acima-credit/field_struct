# frozen_string_literal: true

require_relative 'plugins/cache'

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
