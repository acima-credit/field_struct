# frozen_string_literal: true

module FieldStruct
  module Types
    def self.registry
      @registry ||= Set.new
    end
  end
end

require_relative 'types/check'
require_relative 'types/type'
require_relative 'types/float'
require_relative 'types/integer'
require_relative 'types/string'
require_relative 'types/time'
