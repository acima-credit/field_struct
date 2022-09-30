# frozen_string_literal: true

module FieldStruct
  module Types
    class DateTime < Base
      type :datetime
      base_type ::DateTime

      ISO_DATE = /\A(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})-(\d{2}):(\d{2})\z/.freeze

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
            fallback_string_to_datetime(value)
        elsif interface_coercible?(value)
          value.to_datetime
        end
      end

      def convert_format(value, *args)
        return nil unless args.size == 4

        rx, year_idx, mon_idx, mday_idx, hour_idx, min_idx, sec_idx, offset_idx = args
        match = value.match rx
        return nil unless match

        new_datetime year: (match[year_idx] || 0).to_i,
                     mon: (match[mon_idx] || 0).to_i,
                     mday: (match[mday_idx] || 0).to_i,
                     hour: (match[hour_idx] || 0).to_i,
                     min: (match[min_idx] || 0).to_i,
                     sec: (match[sec_idx] || 0).to_i,
                     offset: (match[offset_idx] || 0).to_i
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

      def fallback_string_to_datetime(value)
        puts ">> fallback_string_to_datetime | value : #{value.inspect}"
        options = base_type._parse(value, false)
        puts ">> fallback_string_to_datetime | options : #{options.inspect}"
        new_datetime(options)
      end

      def new_datetime(options)
        puts ">> new_datetime | options : #{options.inspect}"
        return if options[:year].nil? || (options[:year].zero? && options[:mon].zero? && options[:mday].zero?)

        base_type.new options[:year],
                      options[:mon],
                      options[:mday],
                      options.fetch(:hour, 0),
                      options.fetch(:min, 0),
                      options.fetch(:sec, 0),
                      options.fetch(:offset, 0)
      rescue StandardError => e
        puts ">> new_datetime | Exception : #{e.class.name} : #{e.message}\n  #{e.backtrace[0, 5].join("\n  ")}"
        nil
      end

      def can_coerce?(value)
        string_coercible?(value) || interface_coercible?(value)
      end

      def string_coercible?(value)
        value.is_a?(::String) && !value.empty?
      end

      def interface_coercible?(value)
        value.respond_to?(:to_datetime)
      end
    end

    register_type DateTime
  end
end
