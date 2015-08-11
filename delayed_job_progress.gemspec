# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'delayed_job_progress/version'

Gem::Specification.new do |s|
  s.name          = "delayed_job_progress"
  s.version       = DelayedJobProgress::VERSION
  s.authors       = ["Oleg Khabarov"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/GBH/delayed_job_progress"
  s.summary       = "DelayedJob Progress extension"
  s.description   = "Ability to track jobs against ActiveRecord objects"
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'activerecord',              '>= 4.0.0', '< 5'
  s.add_dependency 'delayed_job',               '>= 4.0'
  s.add_dependency 'delayed_job_active_record', '>= 4.0'
end
