# frozen_string_literal: true

module FieldStruct
  class Basic
    Metadata = Class.new FieldStruct::Metadata

    extend Plugins::Base::ClassMethods
    plugin :base

    self.field_struct_type = :basic
  end

  register_type Basic
end
