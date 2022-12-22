# frozen_string_literal: true

module FieldedStruct
  class Basic
    Metadata = Class.new FieldedStruct::Metadata

    extend Plugins::Base::ClassMethods
    plugin :base

    self.field_struct_type = :basic
  end

  register_type Basic
end
