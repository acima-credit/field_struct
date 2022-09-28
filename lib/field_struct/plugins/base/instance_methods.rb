# frozen_string_literal: true

module FieldStruct
  module Plugins
    module Base
      module InstanceMethods
        def initialize(values = {})
          assign_attributes values
        end

        def assign_attributes(values)
          unless values.respond_to?(:each_pair)
            raise ArgumentError,
                  "When assigning attributes, you must pass a hash as an argument, #{values.class} passed."
          end
          return if values.empty?

          values.map { |name, value| assign_attribute name, value }
        end

        alias attributes= assign_attributes

        def assign_attribute(name, value)
          assign_attribute_with_setter(name, value) || assign_attribute_extra(name, value)
          value
        end

        alias set assign_attribute
        alias []= assign_attribute

        def get_attribute(name)
          send name.to_s
        end

        alias get get_attribute
        alias [] get_attribute

        def metadata
          self.class.metadata
        end

        alias meta metadata

        def attributes
          metadata.attribute_names.each_with_object({}) { |key, hsh| hsh[key] = get key }
        end

        def default_to_hash_options
          {
            compact: false
          }
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
        def to_hash(options = default_to_hash_options)
          values = attributes.each_with_object({}) do |key, hsh|
            value = get key
            hsh[key] = if value.respond_to?(:field_struct?) && value.field_struct?
                         value.to_hash
                       elsif value.is_a?(Array)
                         value.map { |x| x.respond_to?(:field_struct?) && x.field_struct? ? x.to_hash : x }
                       else
                         value
                       end
          end
          values.compact! if options[:compact]
          values
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

        def extras
          @extras ||= {}
        end

        def to_s
          attrs_str = attributes.select { |_k, v| v.present? }.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')
          format '#<%s %s>', self.class.name, attrs_str
        end

        alias inspect to_s

        private

        def assign_attribute_with_setter(name, value)
          setter = :"#{name}="
          return unless respond_to?(setter)

          public_send setter, value
          true
        end

        def assign_attribute_extra(name, value)
          return true if self.class.extras == :ignore
          raise UnknownAttributeError.new(self, name) if self.class.extras == :raise
          raise InvalidKeyError.new(self, name, value) unless name.respond_to?(:to_sym)

          extras[name.to_sym] = value
          true
        end
      end
    end
  end
end
