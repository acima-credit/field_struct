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

  class InvalidKeyError < Error
    attr_reader :record, :key, :value

    def initialize(record, key, value)
      @record = record
      @key = key
      @vlue = value
      super("invalid key '#{key}' for #{@record.class} - key does not respond to 'to_sym'")
    end
  end
end
