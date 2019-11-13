# frozen_string_literal: true

module FieldStruct
  class Error < StandardError
  end

  class TypeError < Error
  end

  class UnknownAttributeError < ActiveModel::UnknownAttributeError
  end

  class BuildError < Error
    # @return [Array<String>]
    attr_reader :errors

    # @param [Hash{Symbol, Array<String>}] errors
    def initialize(errors)
      @errors = errors.map do |field, labels|
        labels.map { |label| ":#{field} #{label}" }
      end.flatten
      super @errors.first
    end
  end
end
