require 'rbs/trace'

RSpec.configure do |config|
  paths = Dir.glob ROOT_PATH.join('lib/**/*.rb')
  trace = RBS::Trace.new paths: paths

  config.before(:suite) { trace.enable }
  config.after(:suite) do
    trace.disable
    out_dir = ROOT_PATH.join('sig/rbs_trace')
    FileUtils.mkdir_p out_dir
    trace.save_files out_dir: out_dir
  end
end