Delayed::Worker.class_eval do
  cattr_accessor :destroy_completed_jobs

  self.destroy_completed_jobs = false
end