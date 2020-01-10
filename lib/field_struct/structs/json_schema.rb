# frozen_string_literal: true

module FieldStruct
  module JsonSchemaSupport
    class JsonSchema
      class Builder
        class << self
          def build(klass)
            new(klass).build
          end

          def build_class_hash(klass)
            return nil unless klass&.respond_to?(:field_struct?) && klass&.field_struct?

            { type: 'object', properties: {} }.tap do |hsh|
              klass.metadata.attributes.each do |key, options|
                (hsh[:required] ||= []) << key.to_s if options[:required]
                hsh[:properties][key] = build_class_hash(options[:type]) || build_column_hash(options)
              end
            end
          end

          def build_column_hash(options)
            hsh = {}

            build_type hsh, options
            build_pattern hsh, options
            build_length hsh, options
            build_min_length hsh, options
            build_max_length hsh, options
            build_enum hsh, options

            hsh
          end

          def build_type(hsh, column)
            type = column[:type]
            if type.respond_to?(:field_struct?) && type.field_struct?
              hsh[:type] = 'object'
              hsh[:items] = { type: 'object' }
              return
            end

            hsh[:type] = case type
                         when :array
                           'array'
                         when :big_integer, :currency, :decimal, :float, :integer
                           'number'
                         when :boolean
                           'boolean'
                         else
                           'string'
                         end
          end

          def build_pattern(hsh, column)
            return unless column[:format]

            hsh[:pattern] = JsRegex.new(column[:format]).to_s
          end

          def build_length(hsh, column)
            return unless column[:length]

            hsh[:minLength] = column[:length].min
            hsh[:maxLength] = column[:length].max
          end

          def build_min_length(hsh, column)
            return unless column[:min_length]

            hsh[:minLength] = column[:min_length]
          end

          def build_max_length(hsh, column)
            return unless column[:max_length]

            hsh[:maxLength] = column[:max_length]
          end

          def build_enum(hsh, column)
            return unless column[:enum]

            hsh[:enum] = column[:enum]
          end
        end

        attr_reader :klass

        def initialize(klass)
          @klass = klass
        end

        def name
          return klass.schema_name if klass.respond_to?(:schema_name)

          klass.name.underscore.gsub '/', '.'
        end

        def basic_hash
          @basic_hash ||= self.class.build_class_hash(klass).deep_stringify_keys
        end

        def full_hash
          basic_hash.merge '$id' => "#{schema_store_url}/#{name}/#{version}.json",
                           '$schema' => 'http://json-schema.org/draft-07/schema#',
                           'description' => "JSON Schema for #{klass.name} version #{version}"
        end

        def version
          Zlib.crc32(basic_hash.to_json, nil).to_s
        end

        attr_writer :schema_store_url

        def schema_store_url
          @schema_store_url || ENV.fetch('SCHEMA_STORE_URL', 'https://schema-store.example.com')
        end

        def json
          full_hash.to_json
        end

        def build
          JsonSchema.new name, full_hash, json, version
        end
      end

      attr_reader :name, :hash, :json, :version

      def initialize(name, hash, json, version)
        @name    = name
        @hash    = hash
        @json    = json
        @version = version
      end
    end

    module ClassMethods
      def json_schema
        return @json_schema if @json_schema && @json_schema.version == metadata.version

        @json_schema = FieldStruct::JsonSchemaSupport::JsonSchema::Builder.build self
      end
    end
    module InstanceMethods
    end
  end
end
