# frozen_string_literal: true

module FieldStruct
  module Types
    class Boolean
      include Type

      def type_class
        ::String
      end

      def coerce(val)
        return val if val.nil? || !val.respond_to?(:to_s)

        %w[true yes y t 1].include? val.to_s.strip.downcase
      end

      private

      def check_type(check)
        return if blank?(check.value)
        return if check.value.is_a?(TrueClass) || check.value.is_a?(FalseClass)

        check << 'is invalid'
      end
    end
  end
end
