# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class Builder
      def self.build(metadata)
        new(metadata).build
      end

      attr_reader :list, :schema

      def initialize(metadata)
        @list   = [metadata]
        @schema = nil
      end

      def build
        make_list
        clean_list
        build_schemas
        schema
      end

      private

      def make_list
        idx = 0
        loop do
          add_type_for idx
          idx += 1
          break if idx >= list.size
        end
      end

      def add_type_for(idx)
        meta = list.at idx
        meta.attributes.each do |_name, attr|
          [attr.type, attr.of].compact.each do |type|
            list << type.metadata if type.field_struct?
          end
        end
      end

      def clean_list
        @list = list.reverse.uniq
      end

      def build_schemas
        @schema = list.map { |x| build_schema_for x }
        @schema = schema.first if schema.size == 1
      end

      def build_schema_for(meta)
        names = meta.schema_name.split('.')
        hsh = {}
        hsh[:type] = 'record'
        hsh[:name] = names.last
        hsh[:namespace] = names[0..-2].join('.')
        hsh[:doc] = "version #{meta.version}"
        hsh[:fields] = meta.attributes.map { |name, attr| build_field_for name, attr }
        hsh
      end

      def build_field_for(name, attr)
        hsh = { name: name }
        add_field_type_for attr, hsh
        add_field_default_for attr, hsh
        add_field_doc_for attr, hsh
        hsh
      end

      def add_field_type_for(attr, hsh)
        hsh[:type] = basic_type_for attr.type, attr
        hsh[:type] = ['null', hsh[:type]] unless attr.required?
      end

      def basic_type_for(type, attr)
        case type
        when :big_integer, :decimal, :float, :currency
          'float'
        when :integer
          'int'
        when :binary
          'bytes'
        when :date, :datetime, :immutable_string, :string, :time
          'string'
        when :boolean
          'boolean'
        when :array
          { type: 'array', items: basic_type_for(attr.of, attr) }
        else
          type.field_struct? ? type.metadata.schema_name : nil
        end
      end

      def add_field_default_for(attr, hsh)
        return if attr.default.nil?
        return if attr.default.is_a?(::Proc)

        hsh[:default] = attr.default
        hsh[:type].reverse! if hsh[:type].is_a?(Array) && hsh[:type].first == 'null'
      end

      def add_field_doc_for(attr, hsh)
        hsh[:doc] = attr.description if attr.description?
      end
    end
  end

  class Metadata
    def as_avro_schema
      AvroSchema::Builder.build self
    end

    def to_avro_json
      as_avro_schema.to_json
    end

    def to_avro_schema
      Avro::Schema.parse to_avro_json
    end
  end
end
