# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'field_struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'field_struct'
  spec.version       = FieldStruct::VERSION
  spec.authors       = ['Adrian Esteban Madrid']
  spec.email         = ['adrian.madrid@acimacredit.com']

  spec.summary       = 'A simple struct with typed attributes'
  spec.description   = 'A simple struct with typed attributes'
  spec.homepage      = 'http://github.com/acimacredit/field_struct'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    # spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  
  spec.add_development_dependency 'bundler', '> 1.16'
  spec.add_development_dependency 'rake', '> 10.0'
  spec.add_development_dependency 'rspec', '> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
end
