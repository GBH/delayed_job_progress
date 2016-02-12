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
  def explode
    raise 'hell'
  end
end

class TestJob < Struct.new(:thing_id)
  def enqueue(job)
    job.record            = Thing.find(thing_id)
    job.identifier        = 'unique_identifier'
    job.progress_max      = 1000
    job.progress_current  = 500
    job.message           = 'initialized'
    job.queue             = 'reports'
  end

  def before(job)
    @job = job
  end

  def perform
    @job.update_column(:message, 'complete')
  end
end
