require_relative './test_helper'
require_relative '../lib/generators/delayed_job/progress_generator'

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../tmp', File.dirname(__FILE__))

  tests DelayedJob::ProgressGenerator

  def test_generator
    run_generator
    assert_migration 'db/migrate/add_progress_to_delayed_jobs.rb'
  end

end