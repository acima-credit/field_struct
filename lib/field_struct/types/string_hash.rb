# frozen_string_literal: true

module FieldStruct
  module Type
    class StringHash < ActiveModel::Type::Value
      def type
        :string_hash
      end

      private

      def cast_value(value)
        case value
        when nil
          value
        when Hash
          value.to_h { |k, v| [k.to_s, v.to_s] }.with_indifferent_access
        when Enumerable
          cast_value value.each_slice(2).to_h
        else
          raise "unknown value type [#{value.class.name}]"
        end
      end
    end
  end
end

ActiveModel::Type.register :string_hash, FieldStruct::Type::StringHash
