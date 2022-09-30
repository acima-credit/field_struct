# frozen_string_literal: true

module FieldStruct
  module Types
    class Base
      class << self
        def default_type
          name.gsub('FieldStruct::Types', '').underscore.to_sym
        end

        NO_VALUE = :no_value

        def type(value = NO_VALUE)
          @type = value unless value == NO_VALUE
          @type || default_type
        end

        def base_type(value = NO_VALUE)
          @base_type = value unless value == NO_VALUE
          @base_type
        end

        # @param [Array] values
        def base_types(*values)
          @base_type = values.flatten.compact unless values.empty?
          @base_type
        end
      end

      # @param [FieldStruct::Attribute] attribute
      def initialize(attribute)
        @attribute = attribute
      end

      def type
        self.class.type
      end

      def base_type
        self.class.base_type
      end

      def coercible?(value)
        return false if value.nil?

        native?(value) || compatible?(value)
      end

      # rubocop:disable Metrics/AbcSize
      def coerce(value)
        return nil if value.nil?
        return value if native?(value)
        return nil if should_not_coerce?
        return nil unless can_coerce?(value)

        coerce_value(value).tap { |x| puts ">> #{type} : coerce | x (#{x.class.name}) #{x.inspect}" }
      rescue StandardError => e
        puts ">> #{type} : coerce | Exception : #{e.class.name} : #{e.message}\n  #{e.backtrace[0, 5].join("\n  ")} ..."
        nil
      end
      # rubocop:enable Metrics/AbcSize

      def ==(other)
        self.class == other.class &&
          meta == other.meta
      end

      alias eql? ==

      private

      def native?(value)
        return false if base_type.blank?
        return base_type.any? { |x| value.is_a?(x) } if base_type.is_a?(Array)

        value.is_a? base_type
      end

      def compatible?(value)
        return false if should_not_coerce?

        can_coerce?(value)
      end

      def should_coerce?
        @attribute && !!@attribute[:coercible]
      end

      def should_not_coerce?
        !should_coerce?
      end

      def can_coerce?(_value)
        true
      end

      def coerce_value(value)
        value
      end
    end
  end
end
