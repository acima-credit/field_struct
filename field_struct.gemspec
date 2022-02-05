# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'field_struct/version'

Gem::Specification.new do |spec|
  spec.name = 'field_struct'
  spec.authors = ['Adrian Esteban Madrid']
  spec.email = ['adrian.madrid@acimacredit.com']
  
  current_branch = `git branch --remote --contains | sed "s|[[:space:]]*origin/||"`.strip
  branch_commit = `git rev-parse HEAD`.strip[0..6]

  if current_branch == 'master'
    spec.version = FieldStruct::VERSION
  else
    spec.version = "#{FieldStruct::VERSION}-#{branch_commit}"
  end

  spec.summary = 'A simple struct with typed attributes'
  spec.description = 'A simple struct with typed attributes'
  spec.homepage = 'http://github.com/acimacredit/field_struct'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/acima-credit'
  # spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel'
  spec.add_dependency 'digest-crc'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-json_expectations'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'hashdiff'
end
