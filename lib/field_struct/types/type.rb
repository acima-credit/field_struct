# frozen_string_literal: true

module FieldStruct
  module Types
    module Type
      def self.included(base)
        base.extend ClassMethods
        Types.registry << base
      end

      module ClassMethods
        attr_writer :short_name

        def short_name(value = :do_not_set)
          @short_name = value.to_s unless value == :do_not_set
          @short_name || default_short_name
        end

        def default_short_name
          name.split('::').last.downcase
        end
      end

      attr_reader :options

      def initialize(options = {})
        @options = default_options.merge options
      end

      def short_name
        self.class.short_name
      end

      def default?
        options.key? :default
      end

      def default
        return nil unless options[:default]
        return options[:default] unless options[:default].respond_to?(:call)

        options[:default].call
      end

      def coercible?
        options[:coercible]
      end

      def required?
        options[:required]
      end

      def valid?(value)
        val = options[:coercible] ? coerce(value) : value

        check = Check.new val

        check_required check
        check_type check
        check_enum check
        check_format check

        check
      end

      def default_options
        {
          required:  true,
          coercible: false
        }
      end

      private

      def present?(val)
        !val.nil? && !val.to_s.strip.empty?
      end

      def blank?(val)
        !present?(val)
      end

      def check_required(check)
        return unless options[:required]
        return if present?(check.value)

        check << 'is required'
      end

      def check_type(check)
        return if blank?(check.value)
        return if check.value.is_a?(type_class)

        check << 'is invalid'
      end

      def check_enum(check)
        return if options[:enum].nil?
        return if blank?(check.value)
        return if options[:enum].include?(check.value)

        check << 'is not included in list'
      end

      def check_format(check)
        return if options[:format].nil?
        return if blank?(check.value)

        match = check.value.to_s.match options[:format]
        return if match

        check << 'is not in a valid format'
      end
    end
  end
end
