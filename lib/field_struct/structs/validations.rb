# frozen_string_literal: true

module FieldStruct
  class Validations
    def self.build_for(klass, name)
      new(klass, name).build
    end

    attr_reader :klass, :name

    def initialize(klass, name)
      @klass = klass
      @name = name
    end

    def meta
      klass.metadata.get name
    end

    def build
      add_meta_field_struct_validation
      add_meta_required_validation
      add_meta_format_validation
      add_meta_enum_validation
      add_meta_length_in_validation
      add_meta_length_min_validation
      add_meta_length_max_validation

      build_final_options
    end

    private

    def add_meta_field_struct_validation
      return unless meta.type.field_struct?

      klass.validates_each name, allow_nil: true do |record, attr, _value|
        nested_attr = record.send(attr)
        unless nested_attr.valid?
          nested_attr.errors.to_hash.each do |field, labels|
            labels.each { |label| record.errors.add attr, "#{field} #{label}" }
          end
        end
      end
    end

    def add_meta_required_validation
      return unless meta.required?

      if meta.type == :boolean
        klass.validates_inclusion_of name, in: [true, false]
      else
        klass.validates_presence_of name
      end
    end

    def add_meta_format_validation
      return unless meta.format?

      klass.validates_format_of(name, allow_nil: true, with: meta.format)
    end

    def add_meta_enum_validation
      return unless meta.enum?

      klass.validates_inclusion_of name, allow_nil: true, in: meta.enum
    end

    def add_meta_length_in_validation
      return unless meta.min_length? && meta.max_length?

      klass.validates_length_of name, allow_nil: true, in: meta.min_length..meta.max_length
    end

    def add_meta_length_min_validation
      return unless meta.min_length? && !meta.max_length?

      klass.validates_length_of name, allow_nil: true, minimum: meta.min_length
    end

    def add_meta_length_max_validation
      return unless meta.max_length? && !meta.min_length?

      klass.validates_length_of name, allow_nil: true, maximum: meta.max_length
    end

    def build_final_options
      options      = {}
      options[:of] = meta.of if meta.of?
      options[:default] = meta.default unless meta.default.nil?
      options
    end
  end
end
