# frozen_string_literal: true

class FieldStruct
  class Value < Base
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
end
