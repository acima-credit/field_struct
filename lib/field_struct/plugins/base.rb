# frozen_string_literal: true

require_relative 'base/class_methods'
require_relative 'base/instance_methods'

module FieldStruct
  module Plugins
    register_plugin :base, Base
  end
end
