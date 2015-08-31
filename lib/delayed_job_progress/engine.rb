require 'delayed_job'
require 'delayed_job_active_record'

module DelayedJobProgress
  class Engine < ::Rails::Engine
    isolate_namespace DelayedJobProgress

    config.to_prepare do
      require_relative 'extensions/job'
      require_relative 'extensions/worker'
    end
  end
end
