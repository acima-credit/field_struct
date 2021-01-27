# frozen_string_literal: true

module FieldStruct
  class Mutable < Base
    def self.inherited(child)
      super
      child.send :extend, ClassMethods
    end

    module ClassMethods
      def field_struct_type
        :mutable
      end
    end

    # @param [Hash] attributes
    def initialize(attributes = {})
      before_attributes_initialize attributes
      super(attributes)
      after_attributes_initialize attributes
      validate
    end
  end

  # @return [Class]
  def self.mutable
    Mutable
  end

  types[:mutable] = Mutable
end
