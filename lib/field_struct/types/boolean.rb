# frozen_string_literal: true

module FieldStruct
  module Types
    class Boolean < Base
      type :boolean
      base_types ::TrueClass, ::FalseClass

      FALSE_VALUES = %w[0 f false off].to_set.freeze

      private

      def coerce_value(value)
        return nil if value == ''

        !FALSE_VALUES.include?(value.to_s.downcase)
      end

      def can_coerce?(value)
        type_coercible?(value)
      end

      def type_coercible?(value)
        [::String, ::Symbol, ::Integer].any? { |x| value.is_a? x }
      end
    end

    register_type Boolean
  end
end
