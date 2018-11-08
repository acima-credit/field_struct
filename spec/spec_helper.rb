# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'field_struct'
require 'bigdecimal'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
