# frozen_string_literal: true

module FieldedStruct
  module Types
    class Date < Base
      include Helpers::DateTime

      type :date
      base_type ::Date
      interface_meth :to_date

      class << self
        def iso_rx
          @iso_rx ||= /\A(\d{4})-(d{2})-(d{2})\z/.freeze
        end

        def parse_formats
          @parse_formats ||= {
            iso: [iso_rx, 1, 2, 3]
          }
        end
      end

      private

      def native?(value)
        super && value.instance_of?(base_type)
      end

      def convert_format(value, *args)
        return nil unless args.size == 4

        rx, year_idx, mon_idx, mday_idx = args
        match = value.match rx
        return nil unless match

        build_instance year: match[year_idx].to_i,
                       mon: match[mon_idx].to_i,
                       mday: match[mday_idx].to_i
      rescue StandardError
        nil
      end

      def fallback_string(value)
        options = base_type._parse(value, false)
        build_instance(options)
      end

      def build_instance(options)
        return if options[:year].nil? || (options[:year].zero? && options[:mon].zero? && options[:mday].zero?)

        base_type.new(options[:year], options[:mon], options[:mday])
      rescue StandardError
        nil
      end
    end

    register_type Date
  end
end
