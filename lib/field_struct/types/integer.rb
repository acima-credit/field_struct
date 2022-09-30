# frozen_string_literal: true

module FieldStruct
  module Types
    class Integer < Base
      type :integer
      base_type ::Integer

      private

      def coerce_value(value)
        value.to_i
      end

      def can_coerce?(value)
        string_coercible?(value) || numeric_coercible?(value)
      end

      def string_coercible?(value)
        value.is_a?(::String) && !!value.to_s.match(/\A\s*[+-]?\d/)
      end

      def numeric_coercible?(value)
        value.is_a?(::Numeric) && value.respond_to?(:to_i)
      end
    end

    register_type Integer
  end
end
