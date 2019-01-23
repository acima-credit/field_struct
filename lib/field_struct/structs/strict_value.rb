# frozen_string_literal: true

module FieldStruct
  class StrictValue < Base
    def initialize(*args)
      super
      validate
    end

    private

    def validate_attribute(attr)
      check = attr.valid? get(attr.name)
      return check if check.valid?

      raise Error, format(':%s %s', attr.name, check.errors.first)
    end
  end

  def self.strict_value
    StrictValue
  end
end
