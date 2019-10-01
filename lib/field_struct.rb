# frozen_string_literal: true

require 'json'
require 'forwardable'

require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'

require_relative 'field_struct/version'
require_relative 'field_struct/types'
require_relative 'field_struct/attribute'
require_relative 'field_struct/attribute_set'
require_relative 'field_struct/error'
require_relative 'field_struct/structs'
