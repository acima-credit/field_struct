# frozen_string_literal: true

module FieldStruct
  module Types
    class Date < Base
      type :date
      base_type ::Date

      ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/.freeze

      def self.parse_formats
        @parse_formats ||= {
          iso: [ISO_DATE, 1, 2, 3]
        }
      end

      def initialize(attribute)
        super

        @parse_format = @attribute.fetch :parse_format, parse_formats[:iso]
      end

      def parse_formats
        self.class.parse_formats
      end

      private

      def native?(value)
        super && value.instance_of?(base_type)
      end

      def coerce_value(value)
        return nil if value == ''

        if string_coercible?(value)
          convert_format(value, *@parse_format) ||
            convert_formats(value) ||
            fallback_string_to_date(value)
        elsif interface_coercible?(value)
          value.to_date
        end
      end

      def convert_format(value, *args)
        return nil unless args.size == 4

        rx, year_idx, mon_idx, mday_idx = args
        match = value.match rx
        return nil unless match

        new_date year: match[year_idx].to_i,
                 mon: match[mon_idx].to_i,
                 mday: match[mday_idx].to_i
      rescue StandardError
        nil
      end

      def convert_formats(value)
        parse_formats.each_value do |*args|
          result = convert_format(value, *args)
          return result unless result.nil?
        end
        nil
      end

      def fallback_string_to_date(value)
        options = base_type._parse(value, false)
        new_date(options)
      end

      def new_date(options)
        return if options[:year].nil? || (options[:year].zero? && options[:mon].zero? && options[:mday].zero?)

        base_type.new(options[:year], options[:mon], options[:mday])
      rescue StandardError
        nil
      end

      def can_coerce?(value)
        string_coercible?(value) || interface_coercible?(value)
      end

      def string_coercible?(value)
        value.is_a?(::String) && !value.empty?
      end

      def interface_coercible?(value)
        value.respond_to?(:to_date)
      end
    end

    register_type Date
  end
end
