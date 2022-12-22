# frozen_string_literal: true

module FieldedStruct
  class Metadata
    class Attribute
      include Comparable

      def initialize(values = {})
        @values = {}
        values.each { |k, v| set k, v }
      end

      def get(name)
        @values[key(name)]
      end

      alias [] get

      def fetch(name, default = nil)
        @values.fetch key(name), default
      end

      def set(name, properties)
        @values[key(name)] = properties
      end

      alias []= set

      def predicate(name)
        @values.key? key(name)
      end

      alias has? predicate

      delegate :inspect, :to_s, :keys, :key?, :delete, to: :@values

      # @return [FieldedStruct::Types::Base, nil]
      def full_type
        return unless type?

        # return type if type.respond_to?(:fielded_struct?) && type.fielded_struct?

        found = Types.get type
        return found.new(self) if found

        nil
      end

      delegate :coercible?, :coerce, to: :full_type

      def <=>(other)
        to_hash <=> other.to_hash
      end

      METH_RX = /\A(\w+)([?=])?\z/i.freeze

      def respond_to_missing?(meth, *)
        match = meth.match METH_RX
        return super unless match

        match[1] ? true : super
      end

      def method_missing(meth, *args)
        match = meth.match METH_RX
        return super unless match

        attr_name = match[1].to_sym
        sign = match[2]

        case sign
        when '?'
          predicate attr_name
        when '='
          set attr_name, args.first
        else
          get attr_name
        end
      end

      def to_hash(options = {})
        @values.each_with_object({}) do |(k, v), hsh|
          next if options && options[:only_keys] && !options[:only_keys].include?(k)

          hsh[k] = to_hash_proc_value(k, v) || to_hash_field_struct_value(v) || v
        end
      end

      private

      def key(name)
        name.to_sym
      end

      def to_hash_proc_value(_key, value)
        return false unless value.is_a?(Proc)

        '<proc>'
      end

      def to_hash_field_struct_value(value)
        return false unless value.respond_to?(:field_Struct?) && value.fielded_struct?

        value.metadata.to_hash
      end
    end
  end
end
