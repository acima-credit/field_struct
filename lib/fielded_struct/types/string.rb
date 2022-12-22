# frozen_string_literal: true

module FieldedStruct
  module Types
    class String < Base
      type :string
      base_type ::String

      DATE_FORMAT = '%Y-%m-%d'
      DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
      TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

      def initialize(attribute)
        super
        @date_format = @attribute.fetch :date_format, DATE_FORMAT
        @datetime_format = @attribute.fetch :datetime_format, DATETIME_FORMAT
        @time_format = @attribute.fetch :time_format, TIME_FORMAT
      end

      private

      def can_coerce?(value)
        value.respond_to?(:to_s)
      end

      def coerce_value(value)
        case value
        when ::BigDecimal
          value.to_f.to_s
        when ::DateTime
          value.strftime @datetime_format
        when ::Date
          value.strftime @date_format
        when ::Time
          value.strftime @time_format
        else
          value.to_s
        end
      end
    end

    register_type String
  end
end
