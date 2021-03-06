# frozen_string_literal: true

module FieldStruct
  class Flexible < Base
    def self.inherited(child)
      super
      child.send :extend, ClassMethods
    end

    module ClassMethods
      def field_struct_type
        :flexible
      end
    end

    # @param [Hash] attributes
    def initialize(attributes = {})
      before_attributes_initialize attributes
      super(attributes)
      after_attributes_initialize attributes
      @attributes.freeze
      validate
    end
  end

  # @return [Class]
  def self.flexible
    Flexible
  end

  types[:flexible] = Flexible
end
