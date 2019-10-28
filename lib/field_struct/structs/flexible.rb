# frozen_string_literal: true

module FieldStruct
  class Flexible < Base
    def self.inherited(child)
      child.send :extend, ClassMethods
    end

    module ClassMethods
      def field_struct_type
        :flexible
      end
    end

    # @param [Hash] attributes
    def initialize(attributes = {})
      super(attributes)
      @attributes.freeze
      validate
    end
  end

  # @return [Class]
  def self.flexible
    Flexible
  end
end
