# frozen_string_literal: true

module StructsHelpers
  extend RSpec::Core::SharedContext
end

RSpec.configure do |config|
  config.include StructsHelpers, type: :struct
end
