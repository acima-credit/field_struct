# frozen_string_literal: true

module FieldStruct
  class Error < StandardError
  end

  class UnknownAttributeError < Error
    attr_reader :record, :attribute

    def initialize(record, attribute)
      @record = record
      @attribute = attribute
      super("unknown attribute '#{attribute}' for #{@record.class}.")
    end
  end
end
