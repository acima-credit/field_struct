# frozen_string_literal: true

module FieldedStruct
  module Types
    module Helpers
      module DateTime
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def iso_rx
            @iso_rx ||= /\A(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})([-+]\d{2}:\d{2})\z/.freeze
          end

          def parse_formats
            @parse_formats ||= {
              iso: [iso_rx, 1, 2, 3, 4, 5, 6, 7]
            }
          end

          def interface_meth(value = :no_value)
            @interface_meth = value unless value == :no_value
            @interface_meth || :unknown
          end
        end

        def initialize(attribute)
          super

          @parse_format = @attribute.fetch :parse_format, parse_formats[:iso]
        end

        def parse_formats
          self.class.parse_formats
        end

        def interface_meth
          self.class.interface_meth
        end

        private

        def coerce_value(value)
          return nil if value == ''

          if string_coercible?(value)
            convert_format(value, *@parse_format) ||
              convert_formats(value) ||
              fallback_string(value)
          elsif interface_coercible?(value)
            coerce_interface(value)
          end
        end

        def convert_formats(value)
          parse_formats.each_value do |*args|
            result = convert_format(value, *args)
            return result unless result.nil?
          end
          nil
        end

        def zone
          ::Time.zone
        end

        def default_offset
          zone&.formatted_offset || 0
        end

        def can_coerce?(value)
          string_coercible?(value) || interface_coercible?(value)
        end

        def string_coercible?(value)
          value.is_a?(::String) && !value.empty?
        end

        def interface_coercible?(value)
          puts ">> interface_coercible? | meth : #{interface_meth.inspect} | res : #{value.respond_to?(interface_meth)}"
          value.respond_to?(interface_meth)
        end

        def coerce_interface(value)
          value.send interface_meth
        end
      end
    end
  end
end
