# frozen_string_literal: true

module FieldStruct
  class Metadata
    attr_reader :name, :schema_name, :attributes, :version

    def initialize(klass)
      @name = klass.name
      @schema_name = klass.schema_name
      @attributes = build_attributes klass
      @version = build_version
    end

    def get(name)
      @attributes[name.to_sym]
    end

    delegate :keys, :[], to: :attributes

    def set(name, key, value)
      @attributes[name.to_sym] ||= {}
      @attributes[name.to_sym][key.to_sym] = value
      @version = build_version
      value
    end

    def to_hash
      {
        name: name,
        schema_name: schema_name,
        attributes: attributes,
        version: version
      }
    end

    private

    def build_attributes(klass)
      return {} unless klass.field_ancestor

      klass.field_ancestor.metadata.attributes.dup
    end

    def build_version
      Zlib.crc32(@attributes.to_json, nil).to_s
    end
  end
end
