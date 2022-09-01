# frozen_string_literal: true

module FieldStruct
  module Plugins
    module Base
      module ClassMethods
        def self.extended(base)
          base.class_attribute :field_struct_type
          base.class_attribute :default_to_hash_options, default: { compact: false }.with_indifferent_access
          base.const_set :Metadata, Class.new(FieldStruct::Metadata) unless base.const_defined?(:Metadata)
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        # @param [Module, Symbol] plugin
        # @param [Array] args
        # @param [Proc] block
        # @return [Module]
        def plugin(plugin, *args, &block)
          plugin = Plugins.load_plugin(plugin) if plugin.is_a?(Symbol)
          raise Error, "Invalid plugin type: #{plugin.class.inspect}" unless plugin.is_a?(Module)

          if !plugin.respond_to?(:load_dependencies) && !plugin.respond_to?(:configure) && (!args.empty? || block)
            Plugins.warn "Plugin #{plugin} does not accept arguments or a block, but arguments or a block was passed " \
                         'when loading this.'
          end

          plugin.load_dependencies(self, *args, &block) if plugin.respond_to?(:load_dependencies)

          include(plugin::InstanceMethods) if defined?(plugin::InstanceMethods)
          extend(plugin::ClassMethods) if defined?(plugin::ClassMethods)

          meta = self::Metadata
          meta.include(plugin::MetadataMethods) if defined?(plugin::MetadataMethods)
          meta.extend(plugin::MetadataClassMethods) if defined?(plugin::MetadataClassMethods)

          plugin.configure(self, *args, &block) if plugin.respond_to?(:configure)

          plugin
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def field_ancestor
          ancestors[1..].find { |x| x.respond_to?(:field_struct?) && x.field_struct? }
        end

        def metadata_class
          return const_get(:Metadata) if const_defined?(:Metadata)

          parent_class = field_ancestor&.metadata_class || ::FieldStruct::Metadata
          const_set :Metadata, Class.new(parent_class)
        end

        def metadata
          return @metadata if instance_variable_defined?(:@metadata)

          @metadata = metadata_class.from(self)
        end

        alias meta metadata

        def from(values = {})
          new values
        end

        def name
          @metadata ? @metadata.name : super
        end

        def short_name
          last, *rest = name.split('::').reverse
          ([last] + rest.map { |x| x.titleize.split.map { |y| y[0, 1] }.join }).reverse.join(':')
        end

        def field_struct?
          true
        end

        def attribute(name, *args, **options)
          arg_options = args.each_with_object({}) { |arg, hsh| hsh[arg.to_sym] = true }
          options = arg_options.merge options

          attribute_metadata name, options
          build_accessors name, options
        end

        private

        def attribute_metadata(name, options = {})
          metadata.set name, options
        end

        def build_accessors(name, _options)
          send :attr_accessor, name
        end
      end

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

          values.each { |name, value| assign_attribute name, value }
        end

        alias attributes= assign_attributes

        def assign_attribute(name, value)
          setter = :"#{name}="
          raise UnknownAttributeError.new(self, name.to_s) unless respond_to?(setter)

          public_send setter, value
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
          metadata.attribute_names.each_with_object(HashWithIndifferentAccess.new) { |key, hsh| hsh[key] = get key }
        end

        def default_to_hash_options
          {
            compact: false
          }
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
        def to_hash(options = default_to_hash_options)
          values = attributes.each_with_object(HashWithIndifferentAccess.new) do |key, hsh|
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

        def to_s
          attrs_str = attributes.select { |_k, v| v.present? }.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')
          format '#<%s %s>', self.class.name, attrs_str
        end

        alias inspect to_s
      end
    end

    register_plugin :base, Base
  end
end
