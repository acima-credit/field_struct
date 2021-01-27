# frozen_string_literal: true

require_relative 'base/attribute'
require_relative 'base/conversion'
require_relative 'base/instance'

module FieldStruct
  class Base
    # @param [Class] child
    def self.inherited(child)
      super
      child.send :include, Comparable
      child.send :include, ActiveModel::Model
      child.send :include, ActiveModel::Attributes
      child.send :include, ActiveModel::Validations
      child.send :include, ActiveModel::Serialization
      child.send :include, ActiveModel::Serializers::JSON

      child.send :extend, AttributeMethods
      child.send :extend, ConversionMethods

      child.send :include, InstanceMethods
    end
  end

  def self.types
    @types ||= {}
  end
end
