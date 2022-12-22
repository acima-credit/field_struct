# frozen_string_literal: true

module FieldedStruct
  class Metadata
    class AttributeSet
      include Comparable

      def initialize(values = {})
        @values = {}
        values.each { |k, v| set k, v }
      end

      def get(name)
        @values[key(name)]
      end

      alias [] get

      def set(name, fields)
        @values[key(name)] = Attribute.new fields
      end

      alias []= set

      def update(attr_name, prop_name, value)
        attr = get(attr_name) || set(attr_name, {})
        attr.set prop_name, value
      end

      def to_hash(options = {})
        @values.transform_values do |v|
          v.to_hash options&.dig(:attribute)
        end
      end

      delegate :map, :each, :keys, :key?, :values, :inspect, :to_s, to: :@values
      alias names keys
      alias attributes values

      def <=>(other)
        to_hash <=> other.to_hash
      end

      private

      def key(name)
        name.to_sym
      end
    end
  end
end
