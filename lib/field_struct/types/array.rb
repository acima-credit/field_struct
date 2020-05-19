# frozen_string_literal: true

module FieldStruct
  module Type
    class Array < ActiveModel::Type::Value
      attr_reader :of
      def initialize(options = {})
        super()
        @of = find_type options
        raise TypeError, 'must provider :of option' unless @of
      end

      def type
        :array
      end

      private

      def find_type(options)
        type = options.delete :of
        return type unless type.is_a?(Symbol)

        ::ActiveModel::Type.registry.lookup type
      end

      def cast_value(value)
        case value
        when nil
          value
        when Enumerable
          value.map { |x| @of.cast x }
        else
          ::Array[@of.cast(value)]
        end
      end
    end
  end
end

ActiveModel::Type.register :array, FieldStruct::Type::Array
