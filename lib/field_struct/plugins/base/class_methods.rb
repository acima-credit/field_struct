# frozen_string_literal: true

module FieldStruct
  module Plugins
    module Base
      module ClassMethods
        def self.extended(base)
          base.class_attribute :field_struct_type
          base.class_attribute :default_to_hash_options, default: { compact: false }.with_indifferent_access
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
          options = build_options(args, options)

          attribute_metadata name, options
          build_accessors name, options
        end

        def extras(value = :no_value)
          @extras = value if %i[add ignore raise].include?(value)
          return @extras if instance_variable_defined?(:@extras)

          return field_ancestor.extras if field_ancestor

          :ignore
        end

        private

        def attribute_metadata(name, options = {})
          metadata.set name, options
        end

        def build_accessors(name, _options)
          send :attr_accessor, name
        end

        def build_options(args, options)
          arg_options = args.each_with_object({}) { |arg, hsh| hsh[arg.to_sym] = true }
          arg_options.merge options
        end
      end
    end
  end
end
