# frozen_string_literal: true

class FieldStruct
  module Types
    class String
      include Type

      def type_class
        ::String
      end

      def coerce(val)
        return val if val.nil?

        val.respond_to?(:to_s) ? val.to_s : val
      end

      private

      def present?(val)
        !val.to_s.strip.empty?
      end
    end
  end
end
