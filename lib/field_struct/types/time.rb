# frozen_string_literal: true

class FieldStruct
  module Types
    class Time
      include Type

      def type_class
        ::Time
      end

      def coerce(val)
        return val unless val.respond_to?(:to_str)

        type_class.parse val.to_str
      rescue ArgumentError
        val
      end
    end
  end
end
