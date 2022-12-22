# frozen_string_literal: true

module FieldedStruct
  module Types
    class DateTime < Base
      include Helpers::DateTime

      type :datetime
      base_type ::DateTime
      interface_meth :to_datetime

      private

      def native?(value)
        super && value.instance_of?(base_type)
      end

      # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      def convert_format(value, regexp = nil, *args)
        return nil unless regexp.present? && args.size >= 3

        match = value.match regexp
        return nil unless match

        build_instance (match[args[0]] || 0).to_i,
                       (match[args[1]] || 0).to_i,
                       (match[args[2]] || 0).to_i,
                       (match[args[3]] || 0).to_i,
                       (match[args[4]] || 0).to_i,
                       (match[args[5]] || 0).to_i,
                       match[args[6]] || 0
      rescue StandardError
        nil
      end
      # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

      def fallback_string(value)
        names = %i[year mon mday hour min sec zone]
        args = base_type._parse(value, false).values_at(*names)
        build_instance(*args)
      end

      # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      def build_instance(*args)
        return if args[0].nil? || (args[0].zero? && args[1].zero? && args[2].zero?)

        base_type.new args[0], args[1], args[2], args[3] || 0, args[4] || 0, args[5] || 0, args[6] || default_offset
      rescue StandardError
        nil
      end
      # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

      def coerce_interface(value)
        new_value = value.send interface_meth
        return new_value if zone.nil?

        if new_value.offset.zero?
          new_value.change offset: zone.formatted_offset
        else
          new_value
        end
      end
    end

    register_type DateTime
  end
end
