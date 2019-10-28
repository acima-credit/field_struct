# frozen_string_literal: true

module FieldStruct
  module Type
    class Array < ActiveModel::Type::Value
      attr_reader :of
      def initialize(options = {})
        super()
        @of = options.delete :of
        raise TypeError, 'must provider :of option' unless @of
      end

      def type
        :array
      end

      private

      def cast_value(value)
        return value unless value.is_a? ::Array

        value.map { |x| @of.cast x }
      end
    end
  end
end

ActiveModel::Type.register :array, FieldStruct::Type::Array
