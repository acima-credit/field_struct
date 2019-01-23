# frozen_string_literal: true

class FieldStruct
  module Types
    class Check
      attr_reader :value, :errors

      def initialize(value)
        @value  = value
        @errors = []
      end

      alias messages errors

      def push(msg)
        @errors << msg
      end

      alias << push

      def valid?
        @errors.empty?
      end
    end
  end
end
