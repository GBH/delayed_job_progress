# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# loading db schema
require 'generators/delayed_job/templates/migration'
require_relative '../lib/generators/delayed_job/templates/progress_migration'

ActiveRecord::Schema.define do
  CreateDelayedJobs.up
  AddProgressToDelayedJobs.new.change

  create_table :things do |t|
    t.string :name
  end
end

class Thing < ActiveRecord::Base
  def something
    update_column(:name, 'processed')
  end
end

class TestJob < Struct.new(:thing_id)
  def enqueue(job)
    job.record            = Thing.find(thing_id)
    job.identifier        = 'unique_identifier'
    job.progress_max      = 1000
    job.progress_current  = 500
    job.progress_state    = 'initialized'
    job.queue             = 'reports'
  end

  def before(job)
    @job = job
  end

  def perform
    @job.update_column(:progress_state, 'complete')
  end
end

class ActiveSupport::TestCase
  # Example usage:
  #   assert_exception_raised                                 do ... end
  #   assert_exception_raised ActiveRecord::RecordInvalid     do ... end
  #   assert_exception_raised Plugin::Error, 'error_message'  do ... end
  def assert_exception(exception_class = nil, error_message = nil, &block)
    exception_raised = nil
    yield
  rescue => exception_raised
  ensure
    if exception_raised
      if exception_class
        assert_equal exception_class, exception_raised.class, exception_raised.to_s
      else
        assert true
      end
      assert_equal error_message, exception_raised.to_s if error_message
    else
      flunk 'Exception was not raised'
    end
  end
end

