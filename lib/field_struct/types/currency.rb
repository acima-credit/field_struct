# frozen_string_literal: true

module FieldStruct
  module Type
    class Currency < ActiveModel::Type::Float
      def type
        :currency
      end

      private

      # @param [Object] value
      def cast_value(value)
        return cast_string(value) if value.is_a? String

        value = super
        value.respond_to?(:round) ? value.round(2) : value
      end

      INVALID_RX = /[^\d$-.,]/.freeze
      REMOVE_RX = /[$,]/.freeze

      # @param [String] str
      def cast_string(str)
        return nil if str.strip.empty?
        return nil if str =~ INVALID_RX

        str.gsub(REMOVE_RX, '').to_f.round(2)
      end
    end
  end
end

ActiveModel::Type.register :currency, FieldStruct::Type::Currency
