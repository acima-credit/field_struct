# frozen_string_literal: true

module FieldStruct
  class Metadata
    class ClassBuilder
      # @param [String, Hash, Array, FieldStruct::Metadata] metadata
      def self.build(metadata, root = nil)
        new.build metadata, root
      end

      # @param [String, Hash, Array, FieldStruct::Metadata] metadata
      def build(metadata, root = nil)
        metadata = Metadata.build(metadata)
        raise "invalid metadata [#{metadata.class.name}]" unless metadata.is_a?(Metadata)

        make_class(metadata, root).tap do |klass|
          metadata.attributes.each do |name, options|
            type = options.delete :type
            klass.attribute name, type, options
          end
        end
      end

      private

      def make_class(metadata, root)
        base = FieldStruct.send metadata.type
        base_root, full_name, last_name = build_constants metadata.name, root
        return base_root.const_get(last_name) if base_root.const_defined?(last_name)

        base_root.const_set(last_name, Class.new(base)).tap do |klass|
          apply_metadata(klass, metadata, full_name)
        end
        base_root.const_get(last_name)
      end

      def build_constants(name, root = nil)
        full_name = root ? (root.to_s + '::' + name) : name
        parts     = full_name.split('::')
        base_root = Object

        parts[0..-2].each do |part|
          base_root = if base_root.const_defined?(part, false)
                        base_root.const_get part, false
                      else
                        base_root.const_set part, Module.new
                      end
        end

        [base_root, full_name, parts.last]
      end

      def apply_metadata(klass, metadata, full_name)
        klass.extras metadata.extras
        klass.metadata.tap do |meta|
          meta.name        = full_name
          meta.schema_name = metadata.schema_name
          meta.extras      = metadata.extras
        end
      end
    end

    class Attribute
      include Comparable

      ATTRIBUTE_NAMES   = %i[type of version required default format enum min_length max_length description].freeze
      ATTRIBUTE_METH_RX = /\A(#{ATTRIBUTE_NAMES.map(&:to_s).join('|')})(\?|\=)?\z/.freeze

      def initialize(values = {})
        @values = {}
        values.each { |k, v| send "#{k}=", v }
      end

      def get(name)
        @values[key(name)]
      end

      alias [] get

      def set(name, value)
        raise "unknown key [#{name}]" unless key?(name)

        @values[key(name)] = value
      end

      alias []= set

      def predicate(name)
        get(name).present?
      end

      def length=(value)
        set :min_length, value.min
        set :max_length, value.max
      end

      def optional=(value)
        set :required, !value unless value
      end

      def optional?
        !required?
      end

      delegate :inspect, :to_s, :keys, :delete, to: :@values

      def <=>(other)
        to_hash <=> other.to_hash
      end

      def respond_to_missing?(meth, *)
        !meth.match(ATTRIBUTE_METH_RX).nil?
      end

      def method_missing(meth, *args)
        match = meth.match ATTRIBUTE_METH_RX
        return super unless match

        name = match[1].to_sym
        type = match[2]

        case type
        when '?'
          predicate name
        when '='
          set name, args.first
        else
          get name
        end
      end

      def to_hash(options = {})
        @values.each_with_object({}) do |(k, v), hsh|
          next if options && options[:only_keys] && !options[:only_keys].include?(k)

          hsh[k] = k == :default && v.is_a?(Proc) ? '<proc>' : v
        end
      end

      private

      def key?(name)
        ATTRIBUTE_NAMES.include? key(name)
      end

      def key(name)
        name.to_sym
      end
    end

    class Attributes
      include Comparable

      def initialize(values = {})
        @values = Hash.new { |hsh, key| hsh[key.to_sym] = Attribute.new }
        values.each { |k, v| set k, v }
      end

      def get(name)
        @values[key(name)]
      end

      alias [] get

      def set(name, fields)
        @values[key(name)] = Attribute.new fields
      end

      def update(name, attr_name, value)
        get(name).set attr_name, value
      end

      alias []= set

      def to_hash(options = {})
        @values.each_with_object({}) do |(k, v), hsh|
          hsh[k] = v.to_hash options&.dig(:attribute)
        end
      end

      delegate :map, :each, :keys, :inspect, :to_s, to: :@values

      def <=>(other)
        to_hash <=> other.to_hash
      end

      private

      def key(name)
        name.to_sym
      end
    end

    def self.default_options
      {
        type: :flexible,
        extras: :ignore
      }
    end

    include Comparable

    class << self
      # Builds a Metadata instance from allowed values
      # @param [FieldStruct::Metadata, String, Hash, Array, Object] value
      # @return [FieldStruct::Metadata]
      def build(value)
        built = build_self(value) || build_string(value) || build_hash(value) || build_array(value)
        raise "unknown value [#{value.class.name}]" unless built

        built
      end

      # Builds a Metadata instance from a FieldStruct class
      #
      # @param [Object] klass
      # @return [FieldStruct::Metadata]
      def from(klass)
        new klass.name.to_s,
            nil,
            build_type(klass),
            klass.extras,
            build_initial_attributes(klass)
      end

      private

      def build_self(value)
        return false unless value.is_a? Metadata

        value
      end

      def build_string(value)
        return false unless value.is_a? String

        YAML.safe_load value, permitted_classes: Metadata
      end

      def build_hash(value)
        return false unless value.is_a? Hash

        new(value[:name], value[:schema_name], value[:type], value[:extras], value[:attributes]).tap do |built|
          built.version = value[:version] if value.key?(:version)
        end
      end

      def build_array(value)
        return false unless value.is_a? Array

        new(*value)
      end

      def build_type(klass)
        klass.respond_to?(:field_struct_type) ? klass.field_struct_type : :missing
      end

      def build_initial_attributes(klass)
        klass.field_ancestor ? klass.field_ancestor.metadata.attributes.to_hash : {}
      end
    end

    attr_reader :name
    attr_accessor :schema_name
    attr_reader :type
    attr_reader :attributes
    attr_accessor :extras
    attr_accessor :version

    def initialize(name, schema_name, type, extras, attributes)
      @name        = name
      @schema_name = schema_name || build_schema_name(name)
      @type        = type || self.class.default_options[:type]
      @extras      = extras || self.class.default_options[:extras]
      @attributes  = Attributes.new attributes
      reset_version
    end

    delegate :keys, :[], to: :attributes

    def name=(value)
      @name = value.to_s.tap do |name|
        @schema_name ||= build_schema_name name
      end
    end

    def get(name)
      @attributes.get name
    end

    alias [] get

    def update(name, values)
      values.each { |k, v| @attributes[name].send "#{k}=", v }.tap { reset_version }
    end

    def reset_version
      @version = build_version attributes: {
        attribute: {
          only_keys: %i[type of required default format enum min_length max_length]
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
      json = @attributes.to_hash(options).to_json
      Zlib.crc32(json, nil).to_s(16)
    end
  end

  def self.from_metadata(meta, prefix = nil)
    Metadata::ClassBuilder.build meta, prefix
  end
end
