# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# loading db schema
require 'generators/delayed_job/templates/migration'
require_relative '../lib/delayed_job_progress/generators/delayed_job/templates/progress_migration'

ActiveRecord::Schema.define do
  CreateDelayedJobs.up
  AddProgressToDelayedJobs.up

  create_table :things do |t|
    t.string :name
  end
end

class Thing < ActiveRecord::Base
  def something
    update_column(:name, 'processed')
  end
end

