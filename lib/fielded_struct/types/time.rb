# frozen_string_literal: true

Time.zone

module FieldedStruct
  module Types
    class Time < Base
      include Helpers::DateTime

      type :time
      base_types ::Time, ::ActiveSupport::TimeWithZone
      interface_meth :to_time

      private

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
                       match[args[6]] || default_offset
      rescue StandardError
        nil
      end
      # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

      def fallback_string(value)
        return ::Time.parse(value) if zone.nil?

        zone.parse value
      end

      # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      def build_instance(*args)
        return if args[0].nil? || (args[0].zero? && args[1].zero? && args[2].zero?)

        final_args = [args[0], args[1], args[2], args[3] || 0, args[4] || 0, args[5] || 0, args[6] || default_offset]
        zone.nil? ? ::Time.new(*final_args) : zone.local(*final_args)
      rescue StandardError
        nil
      end
      # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    end

    register_type Time
  end
end
