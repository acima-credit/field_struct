# frozen_string_literal: true

class FieldStruct
  module Types
    class Float
      include Type

      def type_class
        ::Float
      end

      def coerce(val)
        return val.to_f if val.is_a? Numeric

        coerce_string val.to_s
      end

      private

      INVALID_RX = /[^\d\$-\.\,]/
      REMOVE_RX = /[\$\,]/

      def coerce_string(str)
        return nil if str.strip.empty?
        return nil if str =~ INVALID_RX

        str.gsub(REMOVE_RX, '').to_f
      end
    end
  end
end
