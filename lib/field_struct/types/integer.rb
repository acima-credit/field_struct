# frozen_string_literal: true

module FieldStruct
  module Types
    class Integer
      include Type

      def type_class
        ::Integer
      end

      def coerce(val = original)
        return val unless present?(val)

        val.respond_to?(:to_i) ? val.to_i : val
      end
    end
  end
end
