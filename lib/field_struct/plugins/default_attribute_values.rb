# frozen_string_literal: true

module FieldStruct
  module Plugins
    module DefaultAttributeValues
      module InstanceMethods
        def assign_attributes(values)
          merged_values = meta.default_values.merge values.deep_stringify_keys

          super merged_values
        end
      end

      module MetadataMethods
        def default_values
          attributes.each.with_object({}) do |(name, attr), hsh|
            next unless attr.has? :default

            hsh[name] = attr.get :default
          end
        end
      end
    end

    register_plugin :default_attribute_values, DefaultAttributeValues
  end
end
