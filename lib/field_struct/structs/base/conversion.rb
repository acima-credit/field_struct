# frozen_string_literal: true

module FieldStruct
  class Base
    module ConversionMethods
      # @param [Object] value
      # @return [Object]
      def cast(value)
        return value if value.nil?
        return value if value.is_a?(self)
        return new(value) if value.is_a?(Hash)

        raise "invalid value for casting [#{value.class.name}]"
      end

      # @param [Object] value
      # @return [Boolean]
      def assert_valid_value(value)
        value.is_a?(self) || value.is_a?(Hash)
      end

      # @param [String] json
      def from_json(json)
        new JSON.parse(json)
      end
    end
  end
end
