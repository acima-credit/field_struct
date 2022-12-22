# frozen_string_literal: true

require 'bundler/setup'
require 'fielded_struct'

require 'rspec/core/shared_context'
require 'rspec/json_expectations'
require 'hashdiff'

ROOT_PATH = Pathname.new File.expand_path(File.dirname(File.dirname(__FILE__)))

Time.zone = 'Mountain Time (US & Canada)'
# Time.zone = 'UTC'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Dir[ROOT_PATH.join('spec/support/*.rb')].sort.each { |f| require f }
end
