# frozen_string_literal: true

module FieldStruct
  def self.types
    @types ||= {}
  end

  def self.register_type(klass)
    types[klass.field_struct_type] = klass
  end
end

require_relative 'structs/basic'
