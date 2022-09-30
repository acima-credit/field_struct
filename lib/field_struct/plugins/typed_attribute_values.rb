# frozen_string_literal: true

module FieldStruct
  module Plugins
    module TypedAttributeValues
      module ClassMethods
        def default_attribute_options
          {
            coercible: true
          }
        end

        private

        def build_options(name, args, options)
          options[:type] = args.shift if args.present? && !options.key?(:type)
          super name, args, options
        end

        def build_accessors(name, options)
          super
          build_typed_setter name
        end

        def build_typed_setter(name)
          attr = metadata.get name
          type = attr.full_type
          return unless type

          define_method("#{name}=") do |value|
            instance_variable_set "@#{name}", type.coerce(value)
          end
        end
      end
    end

    register_plugin :typed_attribute_values, TypedAttributeValues
  end
end
