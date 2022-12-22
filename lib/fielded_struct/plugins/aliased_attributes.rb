# frozen_string_literal: true

module FieldedStruct
  module Plugins
    module AliasedAttributes
      module ClassMethods
        private

        def build_accessors(name, options)
          super
          build_aliased_accessors name
        end

        def build_aliased_accessors(name)
          attr = metadata.get name
          aliases = Array[attr[:alias]].flatten
          return if aliases.empty?

          aliases.each do |alias_name|
            define_method(alias_name) do
              send name
            end
            define_method("#{alias_name}=") do |value|
              send "#{name}=", value
            end
          end
        end
      end
    end

    register_plugin :aliased_attributes, AliasedAttributes
  end
end
