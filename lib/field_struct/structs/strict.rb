# frozen_string_literal: true

module FieldStruct
  class Strict < Base
    def self.inherited(child)
      child.send :extend, ClassMethods
    end

    module ClassMethods
      def field_struct_type
        :strict
      end
    end

    # @param [Hash] attributes
    def initialize(attributes = {})
      super(attributes)
      after_attributes_initialize
      @attributes.freeze
      return if valid?

      raise BuildError, errors.to_hash
    end
  end

  # @return [Class]
  def self.strict
    Strict
  end

  types[:strict] = Strict
end
