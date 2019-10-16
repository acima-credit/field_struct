# frozen_string_literal: true

module FieldStruct
  class Flexible < Base
    attr_reader :errors

    def initialize(*args)
      super
      validate
    end

    def valid?
      errors.empty?
    end

    private

    def validate
      @errors = []
      super
      valid?
    end

    def validate_attribute(attr)
      check = attr.valid? get(attr.name)
      return check if check.valid?

      check.errors.each { |x| errors << format(':%s %s', attr.name, x) }
      check
    end
  end

  def self.flexible
    Flexible
  end
end
