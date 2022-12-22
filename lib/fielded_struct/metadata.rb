# frozen_string_literal: true

require_relative 'metadata/attribute'
require_relative 'metadata/attribute_set'

module FieldedStruct
  class Metadata
    class << self
      def default_options
        @default_options ||= {
          type: :flexible,
          extras: :ignore
        }
      end

      def from(klass)
        new klass.name.to_s,
            nil,
            build_type(klass),
            klass.extras,
            build_initial_attributes(klass)
      end

      private

      def build_type(klass)
        klass.respond_to?(:field_struct_type) ? klass.field_struct_type : :missing
      end

      def build_initial_attributes(klass)
        klass.field_ancestor ? klass.field_ancestor.metadata.attributes.to_hash : {}
      end
    end

    include Comparable

    attr_reader :name, :type, :attributes
    attr_accessor :schema_name, :version, :extras

    def initialize(name, schema_name, type, extras, attributes)
      @name = name
      @schema_name = schema_name || build_schema_name(name)
      @type = type || self.class.default_options[:type]
      @extras = extras || self.class.default_options[:extras]
      @attributes = AttributeSet.new attributes
      reset_version
    end

    delegate :map, :each, :keys, :[], to: :attributes

    def name=(value)
      @name = value.to_s.tap do |name|
        @schema_name ||= build_schema_name name
      end
    end

    def short_name
      last, *rest = self.class.name.split('::').reverse
      ([last] + rest.map { |x| x.titleize.split.map { |y| y[0, 1] }.join }).reverse.join(':')
    end

    delegate :set, :[]=, :get, :[], :keys, :key?, :values, to: :attributes
    alias attribute_names keys
    alias attribute_values values

    def update(attr_name, values)
      values.each { |k, v| @attributes.update attr_name, k, v }.tap { reset_version }
    end

    def reset_version
      @version = build_version version_attribute_options
    end

    def version_attribute_options
      {
        attributes: {
          attribute: {
            only_keys: %i[name type of required default format enum min_length max_length]
          }
        }
      }
    end

    def to_hash(options = {})
      {
        name: name,
        schema_name: schema_name,
        attributes: attributes.to_hash(options&.dig(:attributes)),
        version: version
      }
    end

    def <=>(other)
      to_s <=> other.to_s
    end

    def to_s
      format '#<%s name=%s version=%s type=%s>',
             self.class.name,
             name.inspect,
             version.inspect,
             type.inspect
    end

    alias inspect to_s

    private

    def build_schema_name(value)
      value.to_s.underscore.gsub '/', '.'
    end

    def build_version(options = {})
      hash = @attributes.to_hash(options)
      Digest::CRC32.hexdigest(hash.to_json)
    end
  end
end
