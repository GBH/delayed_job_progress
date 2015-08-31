$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "delayed_job_progress/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'delayed_job_progress'
  s.version     = DelayedJobProgress::VERSION
  s.authors     = ["Oleg Khabarov"]
  s.email       = ["oleg@khabarov.ca"]
  s.homepage    = "http://github.com/GBH/delayed_job_progress"
  s.summary     = "DelayedJob Progress extension"
  s.description = "Ability to track jobs against ActiveRecord objects"
  s.license     = 'MIT'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = Dir["test/**/*"]

  s.add_dependency 'rails',                     '>= 4.0.0', '< 5'
  s.add_dependency 'delayed_job',               '>= 4.0'
  s.add_dependency 'delayed_job_active_record', '>= 4.0'

  s.add_development_dependency 'sqlite3'
end
